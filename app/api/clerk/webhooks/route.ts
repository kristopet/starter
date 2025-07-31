import { headers } from "next/headers"
import { Webhook } from "svix"
import { WebhookEvent } from "@clerk/nextjs/server"
import { createCustomer } from "@/actions/customers"

export async function POST(req: Request) {
  // Get headers
  const headerPayload = await headers()
  const svix_id = headerPayload.get("svix-id")
  const svix_timestamp = headerPayload.get("svix-timestamp")
  const svix_signature = headerPayload.get("svix-signature")

  // Get body
  const body = await req.text()
  const webhookSecret = process.env.CLERK_WEBHOOK_SECRET

  // Verify webhook
  const wh = new Webhook(webhookSecret!)
  let evt: WebhookEvent

  try {
    if (!svix_id || !svix_timestamp || !svix_signature || !webhookSecret) {
      throw new Error("Webhook headers or secret missing")
    }

    evt = wh.verify(body, {
      "svix-id": svix_id,
      "svix-timestamp": svix_timestamp,
      "svix-signature": svix_signature,
    }) as WebhookEvent
  } catch (err) {
    console.error("Webhook verification failed:", err)
    return new Response(
      JSON.stringify({ error: "Webhook verification failed" }), 
      { status: 400 }
    )
  }

  // Handle user.created event
  if (evt.type === "user.created") {
    console.log(`[Clerk Webhook] Processing user.created for ${evt.data.id}`)
    
    try {
      // Check if customer already exists (in case of duplicate webhook)
      const { getCustomerByUserId } = await import("@/actions/customers")
      const existingCustomer = await getCustomerByUserId(evt.data.id)
      
      if (existingCustomer) {
        console.log(`[Clerk Webhook] Customer already exists for ${evt.data.id}`)
        return new Response(JSON.stringify({ received: true }), { status: 200 })
      }
      
      const result = await createCustomer(evt.data.id)
      if (!result.isSuccess) {
        console.error(`[Clerk Webhook] Failed to create customer for ${evt.data.id}`)
        // Return 200 to prevent Clerk from retrying immediately
        // The dashboard layout will create the customer on demand
        return new Response(
          JSON.stringify({ received: true, warning: "Customer creation deferred" }), 
          { status: 200 }
        )
      }
      console.log(`[Clerk Webhook] Customer created successfully for ${evt.data.id}`)
    } catch (error) {
      console.error(`[Clerk Webhook] Error creating customer for ${evt.data.id}:`, error)
      // Return 200 to prevent Clerk from retrying immediately
      // The dashboard layout will create the customer on demand
      return new Response(
        JSON.stringify({ received: true, warning: "Customer creation deferred", error: String(error) }), 
        { status: 200 }
      )
    }
  }

  return new Response(JSON.stringify({ received: true }), { status: 200 })
}