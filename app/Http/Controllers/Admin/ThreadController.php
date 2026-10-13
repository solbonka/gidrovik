<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreThreadRequest;
use App\Http\Requests\Admin\UpdateThreadRequest;
use App\Models\Thread;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class ThreadController extends Controller
{
    public function index(): Response
    {
        $threads = Thread::query()
            ->withCount('connections')
            ->orderBy('system')
            ->orderBy('designation')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/threads/Index', [
            'threads' => $threads,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/threads/Create');
    }

    public function store(StoreThreadRequest $request): RedirectResponse
    {
        Thread::query()->create($request->validated());

        return to_route('admin.threads.index')
            ->with('success', 'Резьба успешно создана.');
    }

    public function edit(Thread $thread): Response
    {
        return Inertia::render('admin/threads/Edit', [
            'thread' => $thread,
        ]);
    }

    public function update(
        UpdateThreadRequest $request,
        Thread $thread,
    ): RedirectResponse {
        $thread->update($request->validated());

        return to_route('admin.threads.index')
            ->with('success', 'Резьба успешно обновлена.');
    }

    public function destroy(Thread $thread): RedirectResponse
    {
        if ($thread->connections()->exists()) {
            return to_route('admin.threads.index')
                ->with(
                    'error',
                    'Нельзя удалить резьбу, которая используется товарами.',
                );
        }

        $thread->delete();

        return to_route('admin.threads.index')
            ->with('success', 'Резьба удалена.');
    }
}
