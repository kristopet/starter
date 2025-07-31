import { getCustomerByUserId } from "@/actions/customers"
import { SelectCustomer } from "@/db/schema/customers"
import { currentUser } from "@clerk/nextjs/server"
import { Header } from "./header"

export async function HeaderWrapper() {
  const user = await currentUser()
  let membership: SelectCustomer["membership"] | null = null

  if (user) {
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
        console.error("[HeaderWrapper] Failed to create customer on demand:", error)
      }
    }
    
    membership = customer?.membership ?? "free"
  }

  return <Header userMembership={membership} />
}
