# TaskFlow

TaskFlow is a Flutter-based task management application developed as
part of the Flutter Developer Assessment.

## Features

### Authentication

-   Email and password login
-   Persistent login/session handling
-   Authentication error handling
-   Logout support

### Task Management

-   View tasks
-   Create tasks
-   Edit task title and description
-   Change task status
-   Delete tasks
-   View task details

Supported task statuses: - Todo - In Progress - Completed

### Real-Time Updates

-   Task list and task detail update live when a task is created,
    updated or deleted from another client
-   Automatic WebSocket reconnection with a connection status banner

### Offline Support

-   Previously loaded tasks stay available without a connection
-   Tasks can be created, edited and deleted offline
-   Changes are stored on the device and synchronized when the
    connection is back

### Responsive UI

The application is designed to adapt to: - Mobile - Tablet - Desktop -
Ultra HD displays

### UI States

The application handles: - Loading states - Empty states - Error
states - Offline state - Sync state - WebSocket connection state - Form
validation states - API error states

## Architecture

The project follows Clean Architecture with a separation between:

``` text
Presentation
    ↓
Domain
    ↓
Data
    ↓
Remote / Local Data Source
    ↓
API / Database
```

Feature modules are organized into:

``` text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

Each API operation (create, update, delete, get detail) has its own data
source, repository, use case and bloc. Dependencies are registered with
`get_it` in `lib/core/di/injection.dart`.

## State Management

The application uses **flutter_bloc** for state management.

BLoCs are separated by feature and responsibility. For example:

-   `LoginBloc` handles authentication form and login state.
-   `TasksBloc` handles task listing, refresh, pagination, loading and
    error states, and applies WebSocket and offline changes to the list.
-   `CreateTaskBloc` handles create-task form state and task creation.
-   `TaskDetailBloc` handles task detail loading, inline editing, status
    change, delete, and live updates for the open task.

Each screen keeps its state in one state class, so every UI state
(loading, empty, error, loaded, refreshing) is explicit.

## Networking

The application uses **Dio** for REST API communication, wrapped in
`ApiClient`. It adds the bearer token and maps errors to
`ApiException`, `NetworkException` and `TimeoutApiException`.

Backend base URL:

``` text
https://ff64-122-167-97-59.ngrok-free.app/
```

Swagger documentation:

``` text
https://ff64-122-167-97-59.ngrok-free.app/docs
```

The URL is set in `lib/core/config/server_config.dart`. The ngrok URL
changes when the tunnel is restarted, so update `baseUrl` there if
requests fail. The WebSocket URL is derived from it.

## Local Storage and Offline Synchronization

### Local storage

-   **Drift (SQLite)** stores tasks and the queue of pending changes
    (`tasks` and `pending_changes` tables).
-   **shared_preferences** stores the session (token and user details)
    through `UserDetails`.

Drift was chosen because the sync queue needs transactions: a task row
and its queued change are written together or not at all.

### How offline synchronization works

1.  Every successful fetch is cached in the `tasks` table. If a request
    fails because there is no connection or it times out, the list,
    detail screen and edits fall back to the cache.
2.  Creating, editing or deleting a task while the server cannot be
    reached writes to the database and adds a row to `pending_changes`
    in one transaction. Nothing is lost if the app is closed.
    -   A task created offline gets a temporary negative id and a
        generated `local_id`.
    -   Several edits to the same task are merged into one queued
        change. The original base version is kept so the server can
        detect conflicts.
    -   Deleting a task the server never saw removes it outright; any
        other task is hidden and a delete is queued.
3.  Each task has a sync state (`synced`, `pendingCreate`,
    `pendingUpdate`, `pendingDelete`, `failed`). The task card shows a
    small icon for tasks that are waiting or failed.
4.  `TaskSyncService` sends the queue to `POST /sync`, oldest change
    first, in batches of 50. It runs when the tasks screen opens, when
    the device goes back online, when the WebSocket reconnects, shortly
    after an offline save, and on an exponential backoff (up to 30 s)
    while the server cannot be reached.
5.  Results are matched to changes by `local_id` (create) or `task_id`
    (update, delete):
    -   `synced`: the change leaves the queue. For a create, the
        temporary id is replaced by the server id and the list and
        detail screens are told about the new id.
    -   `conflict`: last write wins. The update is sent again on top of
        the server's current version. If it conflicts a second time the
        task is marked `failed`.
    -   A whole batch rejected with a 4xx is retried one change at a
        time so only the bad change is marked `failed`.
    -   Network errors, timeouts and 5xx keep the queue and retry
        later. A 401 pauses syncing until the next start.
6.  Edits made while a change is being sent stay queued on top of the
    new server version. A task deleted while its create is being sent
    is deleted on the server afterwards.
7.  Fresh server data never overwrites a row that still has a pending
    change.

## WebSocket

`TaskSocketService` keeps one connection to the provided WebSocket
endpoint open while the user is logged in.

WebSocket endpoint:

``` text
wss://ff64-122-167-97-59.ngrok-free.app/ws
```

### Real-time updates

-   `task_created`, `task_updated` and `task_deleted` messages become
    typed events. `TasksBloc` and `TaskDetailBloc` listen to them, so
    changes made elsewhere show up without a refresh.
-   Stale updates (older version than the one shown) and duplicates
    (the same task arriving twice) are ignored.

### Connection failures and reconnection

-   If the connection fails or closes, it reconnects with exponential
    backoff (1, 2, 4, 8, 16, then 30 seconds).
-   After a reconnect, events sent while disconnected were missed, so
    the list and detail blocs reload and the sync queue runs.
-   A banner at the bottom of the screen shows the state: offline,
    syncing, sync will retry, reconnecting to live updates, or live
    updates off. It is hidden when everything is fine.
-   Logout closes the socket and stops syncing.

## Project Structure

``` text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── database/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── responsive/
│   ├── router/
│   ├── socket/
│   ├── storage/
│   ├── sync/
│   ├── theme/
│   └── widgets/
│
└── features/
    ├── auth/
    ├── tasks_home/
    ├── create_task/
    └── task_detail/

test/
├── core/sync/
├── features/
└── helpers/
```

## Main Screens

The application uses three main screens:

1.  **Login**
2.  **Tasks Home**
3.  **Task Details**

Create and edit operations are handled through dialogs and inline
interactions rather than additional navigation pages.

## Platform Support

| Platform | Status |
| -------- | ------ |
| Windows  | Tested |
| Android  | Not set up yet |
| Web      | Drift is not set up yet |
| iOS, macOS, Linux | Not tested |

-   **Windows:** all testing so far was done on the Windows desktop
    build.
-   **Android:** platform setup is not done (for example the `INTERNET`
    permission for release builds). Not run on an Android device or
    emulator yet.
-   **Web:** Drift needs `sqlite3.wasm` and `drift_worker.js` in the
    `web/` folder and the `web:` options passed to `driftDatabase`.
    This is not set up, so the app's local database will not work on
    web.

## Getting Started

### Prerequisites

-   Flutter SDK
-   Dart SDK
-   Android Studio / Xcode or another supported Flutter development
    environment

### Installation

Clone the repository and run:

``` bash
flutter pub get
```

The generated Drift file `lib/core/database/app_database.g.dart` is
included. If it is missing or you change the tables, regenerate it:

``` bash
dart run build_runner build --delete-conflicting-outputs
```

### Run

``` bash
flutter run -d windows
```

### Tests

``` bash
flutter test
```

Tests cover the sync service, the task list bloc, the offline create
path and the sync models.

## Test Account

``` text
Email: candidate@test.com
Password: password123
```

## Dependencies

Key packages used:

-   `flutter_bloc` - State management
-   `go_router` - Navigation
-   `dio` - REST API communication
-   `web_socket_channel` - WebSocket communication
-   `connectivity_plus` - Network connectivity detection
-   `drift` / `drift_flutter` - Local SQLite database
-   `shared_preferences` - Session storage
-   `get_it` - Dependency injection
-   `dartz` - Either-based error handling in use cases
-   `google_fonts` - Typography
-   `flutter_staggered_grid_view` - Responsive task grid
-   `motion_toast` - User feedback

## Known Limitations

-   Tested on Windows only. Android setup is not done and Drift is not
    set up for web (see Platform Support).
-   Logging out clears the local database, including changes that have
    not synced yet. The logout dialog warns about this.
-   WebSocket events update the screen but are not written to the local
    database, so the cache catches up on the next fetch.
-   Connectivity detection reports whether the device has a network
    connection, not whether the server is reachable. Requests handle
    their own failures.
-   A task created offline and synced while its detail screen is open is
    tracked by its new id internally; reopening it from the list is the
    safe path.

## Author

**Ashwanth V Praveen**