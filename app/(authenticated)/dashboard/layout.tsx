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

  console.log(`[Dashboard Layout] Checking customer for user ${user.id}`)
  let customer = await getCustomerByUserId(user.id)

  // If no customer record exists, create one (webhook may not have fired yet)
  if (!customer) {
    console.log(`[Dashboard Layout] No customer found for user ${user.id}, creating one...`)
    try {
      const { createCustomer } = await import("@/actions/customers")
      const result = await createCustomer(user.id)
      if (result.isSuccess && result.data) {
        customer = result.data
        console.log(`[Dashboard Layout] Customer created successfully for user ${user.id}`)
      } else {
        console.error(`[Dashboard Layout] Failed to create customer for user ${user.id}`)
      }
    } catch (error) {
      console.error(`[Dashboard Layout] Error creating customer for user ${user.id}:`, error)
    }
  } else {
    console.log(`[Dashboard Layout] Customer found for user ${user.id}, membership: ${customer.membership}`)
  }

  // Temporarily allow all authenticated users to access dashboard
  // TODO: Re-enable this check once payment flow is implemented
  // if (!customer || customer.membership !== "pro") {
  //   redirect("/?redirect=dashboard#pricing")
  // }

  const userData = {
    name:
      user.firstName && user.lastName
        ? `${user.firstName} ${user.lastName}`
        : user.firstName || user.username || "User",
    email: user.emailAddresses[0]?.emailAddress || "",
    avatar: user.imageUrl,
    membership: customer?.membership || "free"
  }

  return (
    <DashboardClientLayout userData={userData}>
      {children}
    </DashboardClientLayout>
  )
}
