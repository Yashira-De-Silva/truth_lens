<x-mail::message>
# Password Reset Verification

Hello,

You are receiving this email because we received a password reset request for your Truth Lens account.

Your verification code is:

<x-mail::panel>
# {{ $otp }}
</x-mail::panel>

This code will expire in 15 minutes.

If you did not request a password reset, no further action is required.

Thanks,<br>
{{ config('app.name') }}
</x-mail::message>
