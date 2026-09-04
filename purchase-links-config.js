/* Revive & Glow — online purchase links (Mindbody)
 *
 * Paste the Mindbody online-purchase link for each product below.
 * These are PRICING OPTIONS / PACKAGES in Mindbody, not appointment types.
 * If a link is ever emptied, the matching button on booking.html falls back to
 * opening the on-page Mindbody Appointments scheduler, and the client selects the
 * package or membership at checkout.
 *
 * Pricing options (packages) use stype=43; contracts (memberships) use stype=40.
 *
 * Known link pattern already used on this site (intro offers):
 *   https://clients.mindbodyonline.com/classic/ws?studioid=5755152&stype=43&prodid=<PRODUCT ID>
 * Do not guess product IDs — copy the exact link from Mindbody.
 */
window.REVIVE_PURCHASE_LINKS = Object.freeze({
  // 5-Session Wellness Pack — $169 — 5 Revive Sessions — valid 60 days
  // Official Mindbody "Online store link" from the pricing option settings (2026-09-04)
  starter5: 'https://clients.mindbodyonline.com/classic/ws?studioid=5755152&stype=43&prodid=100033',
  // Revive Flex — $179/month — 8 Revive Sessions per billing month
  // Official Mindbody "Online store link" from the contract settings (2026-09-04)
  flex: 'https://clients.mindbodyonline.com/classic/ws?studioid=5755152&stype=40&prodid=100',
  // Revive Elite — $299/month — 15 Revive Sessions per billing month
  // Official Mindbody "Online store link" from the contract settings (2026-09-04)
  elite: 'https://clients.mindbodyonline.com/classic/ws?studioid=5755152&stype=40&prodid=102'
});
