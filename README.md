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

### Responsive UI

The application is designed to adapt to: - Mobile - Tablet - Desktop -
Ultra HD displays

### UI States

The application handles: - Loading states - Empty states - Error
states - Form validation states - API error states

## Architecture

The project follows Clean Architecture with a separation between:

``` text
Presentation
    ↓
Domain
    ↓
Data
    ↓
Remote Data Source
    ↓
API
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

## State Management

The application uses **flutter_bloc** for state management.

BLoCs are separated by feature and responsibility. For example:

-   `LoginBloc` handles authentication form and login state.
-   `TasksBloc` handles task listing, refresh, pagination, loading and
    error states.
-   `CreateTaskBloc` handles create-task form state and task creation.
-   Task detail functionality has its own presentation state management.

## Networking

The application uses **Dio** for REST API communication.

Backend base URL:

``` text
https://ff64-122-167-97-59.ngrok-free.app/
```

Swagger documentation:

``` text
https://ff64-122-167-97-59.ngrok-free.app/docs
```

## Local Storage and Offline Synchronization

Offline persistence and pending-operation synchronization are planned as
part of the application's offline architecture.

The remaining implementation includes: - Persisting previously loaded
tasks locally - Supporting task creation/update while offline -
Persisting pending changes when the application closes - Synchronizing
pending changes when connectivity is restored

## WebSocket

The application is intended to use the provided WebSocket connection for
real-time task updates.

WebSocket endpoint:

``` text
wss://ff64-122-167-97-59.ngrok-free.app/ws
```

The remaining implementation includes: - Listening for task
create/update/delete events - Updating the task list without manual
refresh - Connection failure handling - WebSocket reconnection

## Project Structure

``` text
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── responsive/
│   ├── router/
│   ├── storage/
│   ├── theme/
│   └── widgets/
│
└── features/
    ├── auth/
    ├── tasks_home/
    ├── create_task/
    └── task_detail/
```

## Main Screens

The application uses three main screens:

1.  **Login**
2.  **Tasks Home**
3.  **Task Details**

Create and edit operations are handled through dialogs and inline
interactions rather than additional navigation pages.

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

### Run

``` bash
flutter run
```

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
-   `get_it` - Dependency injection
-   `google_fonts` - Typography
-   `flutter_staggered_grid_view` - Responsive task grid
-   `motion_toast` - User feedback

## Known Limitations

At the current submission stage, the following assessment requirements
are still pending:

-   Offline local task persistence
-   Offline create/update queue
-   Pending-change synchronization after connectivity restoration
-   WebSocket real-time updates
-   WebSocket reconnection and connection-state handling

The core authentication, task CRUD functionality, responsive UI, and
Clean Architecture structure are implemented.

## Author

**Ashwanth V Praveen**
