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
    try {
      const result = await createCustomer(evt.data.id)
      if (!result.isSuccess) {
        console.error("Failed to create customer:", evt.data.id)
        return new Response(
          JSON.stringify({ error: "Failed to create customer" }), 
          { status: 500 }
        )
      }
      console.log("Customer created successfully:", evt.data.id)
    } catch (error) {
      console.error("Error creating customer:", error)
      return new Response(
        JSON.stringify({ error: "Error creating customer" }), 
        { status: 500 }
      )
    }
  }

  return new Response(JSON.stringify({ received: true }), { status: 200 })
}