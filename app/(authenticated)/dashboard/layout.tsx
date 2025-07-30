import { getCustomerByUserId } from "@/actions/customers"
import { currentUser } from "@clerk/nextjs/server"
import { redirect } from "next/navigation"
import DashboardClientLayout from "./_components/layout-client"

export default async function DashboardLayout({
  children
}: {
  children: React.ReactNode
}) {
  const user = await currentUser()

  if (!user) {
    redirect("/login")
  }

  let customer = await getCustomerByUserId(user.id)

  // If no customer record exists, create one (webhook may not have fired yet)
  if (!customer) {
    try {
      const { createCustomer } = await import("@/actions/customers")
      const result = await createCustomer(user.id)
      if (result.isSuccess && result.data) {
        customer = result.data
      }
    } catch (error) {
      console.error("Failed to create customer on demand:", error)
    }
  }

  // Gate dashboard access for pro members only
  if (!customer || customer.membership !== "pro") {
    redirect("/?redirect=dashboard#pricing")
  }

  const userData = {
    name:
      user.firstName && user.lastName
        ? `${user.firstName} ${user.lastName}`
        : user.firstName || user.username || "User",
    email: user.emailAddresses[0]?.emailAddress || "",
    avatar: user.imageUrl,
    membership: customer.membership
  }

  return (
    <DashboardClientLayout userData={userData}>
      {children}
    </DashboardClientLayout>
  )
}
