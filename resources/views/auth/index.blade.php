<x-layouts.auth>
    <x-slot name="title">
        {{ trans('general.welcome') }}
    </x-slot>

    <x-slot name="content">
        <div>
            <img src="{{ asset('public/img/akaunting-logo-green.svg') }}" class="w-16" alt="Akaunting" />

            <h1 class="text-lg my-3">
                {{ trans('general.welcome') }}
            </h1>
        </div>

        <p class="text-sm text-black-500 mb-6">
            {{ trans('auth.login_to') }}
        </p>

        <div class="flex flex-col gap-3">
            <x-link
                href="{{ route('login') }}"
                class="flex items-center justify-center bg-green hover:bg-green-700 text-white px-6 py-2 text-base rounded-lg"
                override="class"
            >
                {{ trans('auth.login') }}
            </x-link>

            <x-link
                href="{{ route('register.public') }}"
                class="flex items-center justify-center bg-white border border-green text-green hover:bg-green-100 px-6 py-2 text-base rounded-lg"
                override="class"
            >
                {{ trans('auth.register') }}
            </x-link>
        </div>
    </x-slot>
</x-layouts.auth>
