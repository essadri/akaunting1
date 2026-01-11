<?php

namespace App\Http\Controllers\Auth;

use App\Abstracts\Http\Controller;
use App\Http\Requests\Auth\PublicRegister as Request;
use App\Jobs\Auth\CreateUser;
use App\Jobs\Common\CreateCompany;

class PublicRegister extends Controller
{
    public function __construct()
    {
        $this->middleware('guest');
    }

    public function index()
    {
        return view('auth.index');
    }

    public function create()
    {
        return view('auth.register.public');
    }

    public function store(Request $request)
    {
        $locale = config('app.locale', 'en-GB');

        $company = dispatch_sync(new CreateCompany([
            'name' => $request->get('company_name'),
            'domain' => '',
            'email' => $request->get('email'),
            'currency' => 'USD',
            'locale' => $locale,
            'enabled' => '1',
        ]));

        dispatch_sync(new CreateUser([
            'name' => $request->get('name'),
            'email' => $request->get('email'),
            'password' => $request->get('password'),
            'locale' => $locale,
            'landing_page' => 'dashboard',
            'companies' => [$company->id],
            'roles' => ['1'],
            'enabled' => '1',
            'send_invitation' => false,
        ]));

        flash(trans('messages.success.added', ['type' => trans_choice('general.users', 1)]))->success();

        return redirect()->route('login');
    }
}
