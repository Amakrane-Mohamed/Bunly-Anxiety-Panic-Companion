abstract final class LegalCopy {
  static const lastUpdated = 'August 30, 2026';

  static String privacyPolicy(String contactEmail) {
    return '''
Privacy Policy
Last updated: $lastUpdated

This Privacy Policy explains how Bunly (“Bunly,” “we,” “us”) collects, uses, and shares information when you use the Bunly iOS app, an anxiety and panic companion (the character is also called Bondly).

Bunly is not medical care, therapy, or diagnosis.

1. Who this applies to
You must be at least 13 years old. We do not knowingly collect personal information from children under 13. If you believe a child under 13 used Bunly, contact us.

2. Information we collect
Profile you give us. First name, birthday, pronouns, and answers about panic, stress, and what you want help with.
Companion content. Check-ins, panic sessions, notes, thanks, widget lines, and similar writing you add in the app. This stays on your device.
Purchases. Subscription status and App Store transaction identifiers, processed by Apple and RevenueCat. We never see your full payment card number.
Device and notifications. An Apple Push Notification token if you allow notifications, plus basic app diagnostics.
On-device storage. Companion memory lives on this device.

3. How we use information
To personalize the companion (your name, plan, and widgets). For example, your first name is used so Bondly can greet you on Today.
To provide subscriptions and restore purchases.
To send check-in notifications if you ask for them. For example, a morning reminder you turned on so Bondly can ask how you feel.
To operate, secure, and fix the app.

We do not sell your personal information. We do not use your notes or check-ins to train public AI models. We do not show third-party advertising in the app today.

4. Who we share with
Apple — App Store billing and push notifications.
RevenueCat — subscription status so the app can unlock Bunly Pro.
Firebase (Google) — optional app infrastructure such as messaging. Companion notes and check-ins are not uploaded as your journal.

These providers process data to run their services. We do not share your notes or check-ins with advertisers.

5. Retention
Companion notes and check-ins stay on this device until you delete them in You → Settings → Delete my data, or until you delete the app. Apple keeps purchase records as required by Apple.

6. Your choices
Delete my data in You → Settings. That removes companion data on this device. It does not cancel an App Store subscription. Cancel in Settings → your name → Subscriptions.
Turn off notifications in Settings.
Request a copy of any account data we hold by emailing $contactEmail.

7. Health-related information
Check-ins, panic tools, and onboarding answers may be considered health-related. We use them only to run the companion for you. We do not use them for advertising.

8. Security
We use HTTPS and established providers. No method of transmission is completely secure.

9. International
If you use Bunly from outside the United States, your information may be processed in the United States, where our providers operate.

10. Changes
We may update this policy. The “Last updated” date will change. If you keep using Bunly after an update, you accept the new policy.

11. Contact
$contactEmail
You can also delete your data in You → Settings → Delete my data.
''';
  }

  static String termsOfUse(String contactEmail) {
    return '''
Terms of Use
Last updated: $lastUpdated

These Terms of Use (“Terms”) are an agreement between you and Bunly for the Bunly iOS app. By downloading or using Bunly you agree to these Terms. If you do not agree, do not use the app.

1. Bunly is a companion, not care
Bunly is a self-help companion for anxiety and panic. It is not a medical device, not therapy, and not counseling. It does not diagnose, treat, or cure any condition. A “wellbeing plan” in the app is a personalization of in-app tools, not a clinical plan.

You are responsible for your own health decisions. Talk to a qualified professional for medical or mental-health advice.

2. Eligibility
You must be at least 13 years old. If you are 13–17, you may use Bunly only with a parent or guardian’s permission.

3. Your data
Companion notes and check-ins live on this device. You can delete that data in You → Settings → Delete my data. That does not cancel an App Store subscription.

4. Subscriptions and payments
Some features require Bunly Pro, sold as auto-renewing subscriptions through the App Store.

Payment is charged to your Apple ID when you confirm. Subscriptions renew unless you cancel at least 24 hours before the end of the current period. Your account is charged for renewal within 24 hours before the period ends, at the then-current price shown in the App Store.

You manage and cancel subscriptions in Settings → your name → Subscriptions. Deleting the app or your on-device data does not cancel a subscription.

If a free trial is offered, the length and price after the trial are shown on the paywall and in the App Store. Unused trial time is forfeited when you buy a subscription.

Prices are set in App Store Connect and shown in your local currency by Apple. Restore purchases is available on the paywall.

5. License
We grant you a personal, non-exclusive, non-transferable license to use Bunly on Apple devices you own or control, as allowed by the App Store terms. You may not copy, reverse engineer, or resell the app, Bondly/Bunly art, or audio, except as allowed by law.

6. Your content
You keep rights to the notes and answers you type. You grant us a limited license to store and display that content so the app can work for you (including Home Screen widgets on your device). We do not claim ownership of your writing.

Do not post content that is illegal, abusive, or that you do not have the right to share.

7. Acceptable use
Do not misuse Bunly, attempt to break it, or use it to harm others. Do not use tester or other unofficial means to unlock paid features.

8. Intellectual property
Bunly, Bondly, the mascot, illustrations, and audio are owned by us or our licensors. Apple, Google, and other marks belong to their owners.

9. Disclaimer
BUNLY IS PROVIDED “AS IS.” TO THE MAXIMUM EXTENT ALLOWED BY LAW, WE DISCLAIM WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR SUITABLE FOR ANY MEDICAL PURPOSE.

10. Limitation of liability
TO THE MAXIMUM EXTENT ALLOWED BY LAW, WE ARE NOT LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR FOR LOSS OF DATA, PROFITS, OR GOODWILL. OUR TOTAL LIABILITY FOR ANY CLAIM ABOUT BUNLY IS LIMITED TO THE GREATER OF (A) THE AMOUNT YOU PAID US FOR BUNLY PRO IN THE 12 MONTHS BEFORE THE CLAIM OR (B) TEN US DOLLARS. SOME PLACES DO NOT ALLOW THESE LIMITS, SO THEY MAY NOT APPLY TO YOU. THIS DOES NOT LIMIT LIABILITY THAT CANNOT BE LIMITED UNDER LAW, INCLUDING FOR GROSS NEGLIGENCE OR WILLFUL MISCONDUCT WHERE SUCH LIMITS ARE FORBIDDEN.

11. Termination
You may stop using Bunly and delete your on-device data at any time. We may suspend or stop the service if you break these Terms or if we shut the app down. Sections that should survive (including 1, 8, 9, and 10) stay in effect.

12. App Store
You also agree to Apple’s App Store terms. Apple is not responsible for Bunly or these Terms. Apple is a third-party beneficiary of this section and may enforce it.

13. Changes
We may update these Terms. The “Last updated” date will change. If you keep using Bunly after an update, you accept the new Terms.

14. Contact
$contactEmail
''';
  }
}
