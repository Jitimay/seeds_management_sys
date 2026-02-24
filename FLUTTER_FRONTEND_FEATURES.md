# Seeds Management System - Flutter Frontend Features

## Project Overview

### What is the Seeds Management System?
The Seeds Management System is a comprehensive agricultural supply chain management platform designed specifically for seed distribution in Burundi. It manages the entire seed lifecycle from pre-base seeds to certified seeds, facilitating transactions between different types of agricultural stakeholders.

### Business Context
The system addresses the agricultural seed supply chain in Burundi, where seeds flow through a hierarchical distribution system:
- **Pré_Bases** (Pre-base seed producers) - Top tier, produce foundation seeds
- **Base** (Base seed producers) - Middle tier, multiply pre-base seeds
- **Certifiés** (Certified seed producers) - Lower tier, produce certified seeds for farmers
- **Cultivateurs** (Farmers/Cultivators) - End users who purchase certified seeds

### Core Business Rules
1. **Hierarchical Supply Chain**: Seeds flow downward through the hierarchy (Pré_Bases → Base → Certifiés → Cultivateurs)
2. **Role-Based Access**: Each user type has specific permissions and can only interact with appropriate tiers
3. **Validation Workflow**: All multiplicators and their stocks require admin validation before becoming active
4. **Traceability**: Complete audit trail of all transactions and stock movements
5. **Quality Control**: Rating system for seed quality and supplier performance

### Key Stakeholders
- **System Administrators**: Validate users, stocks, and oversee the entire system
- **Multiplicators**: Seed producers at various levels who manage inventory and sell to lower tiers
- **Cultivators**: Farmers who purchase certified seeds for cultivation
- **Regulatory Bodies**: Ensure compliance with agricultural standards

### Technical Context
- **Backend**: Django REST API with JWT authentication, role-based permissions, and comprehensive business logic
- **Database**: Relational model with proper constraints and audit trails
- **Integration**: Email notifications, document management, and admin workflows
- **Security**: Multi-level validation, document verification, and secure transactions

### Project Goals
1. **Digitize** the traditional seed distribution system
2. **Ensure traceability** throughout the supply chain
3. **Maintain quality standards** through validation and rating systems
4. **Facilitate transactions** between different stakeholder levels
5. **Provide transparency** in pricing and availability
6. **Enable efficient inventory management** with loss tracking
7. **Support regulatory compliance** through proper documentation

### Success Metrics
- Reduced time for seed procurement
- Improved seed quality through ratings
- Better inventory management
- Enhanced traceability and compliance
- Increased farmer access to quality seeds

## Architecture Overview
- **State Management**: Flutter BLoC Pattern
- **API Integration**: HTTP/Dio with JWT Authentication
- **Local Storage**: SharedPreferences/Hive for offline data
- **Navigation**: GoRouter/AutoRoute
- **UI Framework**: Material Design 3

## Core BLoC Structure

### Authentication BLoC
- **States**: `AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthFailure`, `AuthLoggedOut`
- **Events**: `LoginRequested`, `RegisterRequested`, `LogoutRequested`, `TokenRefreshRequested`, `PasswordResetRequested`

### User Management BLoC
- **States**: `UserInitial`, `UserLoading`, `UserLoaded`, `UserError`
- **Events**: `LoadUserProfile`, `UpdateUserProfile`, `ValidateUser`

## Feature Modules

### 1. Authentication Module

#### Login Screen
- Email/Username input field
- Password input field
- Remember me checkbox
- Login button with loading state
- Forgot password link
- Register navigation

#### Registration Screen
- User type selection (Multiplicator/Cultivator)
- Personal information form:
  - First name, Last name
  - Email, Username, Password
  - Phone number, Alternative phone
  - Province, Commune, Colline
- Document upload (for multiplicators)
- Terms acceptance checkbox
- Submit with validation

#### Password Reset
- Email input screen
- Reset confirmation screen
- New password setup screen

### 2. Dashboard Module

#### Multiplicator Dashboard
- Welcome message with user info
- Quick stats cards:
  - Total stocks
  - Active orders
  - Revenue summary
- Recent activities list
- Navigation shortcuts

#### Cultivator Dashboard
- Available certified seeds
- Order history
- Recommendations
- Local weather info (optional)

#### Admin Dashboard
- Pending validations counter
- System statistics
- Quick action buttons
- Recent registrations

### 3. Stock Management Module

#### Stock List Screen
- Filterable/searchable stock list
- Category tabs (Pré_Bases, Base, Certifiés)
- Stock cards showing:
  - Variety name and image
  - Quantity available
  - Price per unit
  - Expiration date
  - Validation status

#### Add Stock Screen
- Category selection
- Variety dropdown/search
- Quantity input
- Price setting
- Expiration date picker
- Details/notes field
- Image upload
- Submit button

#### Stock Details Screen
- Complete stock information
- Edit/delete options (if owner)
- Order button (if buyer)
- Rating/reviews section
- Seller information

### 4. Order Management Module

#### Order List Screen
- Tabs: Active, Delivered, History
- Order cards with:
  - Stock details
  - Quantity and total price
  - Order status
  - Delivery date
  - Action buttons

#### Place Order Screen
- Stock selection
- Quantity input with validation
- Price calculation
- Delivery preferences
- Confirmation dialog
- Payment method selection

#### Order Details Screen
- Complete order information
- Status tracking
- Delivery confirmation (seller)
- Rating option (buyer)
- Invoice/receipt view

### 5. Plant & Variety Management

#### Plants List Screen
- Grid/list view toggle
- Search functionality
- Add plant button (admin)
- Plant cards with images

#### Plant Details Screen
- Plant information
- Associated varieties list
- Edit/delete options (admin)

#### Varieties List Screen
- Filterable by plant
- Search functionality
- Variety cards with details
- Add variety button (admin)

#### Add/Edit Variety Screen
- Plant selection
- Botanical information form
- Characteristics input
- Image upload
- Origin details
- Submit/update button

### 6. Profile Management Module

#### Profile Screen
- User avatar and basic info
- Account settings
- Role information
- Document status
- Edit profile button

#### Edit Profile Screen
- Editable user information
- Document re-upload
- Password change option
- Save changes button

#### Role Management Screen
- Current roles display
- Request new role option
- Role status tracking
- Document upload per role

### 7. Loss Management Module

#### Loss List Screen
- Loss history with filters
- Date range selection
- Total loss summary
- Add loss button

#### Add Loss Screen
- Stock selection dropdown
- Quantity input
- Reason/details field
- Date picker
- Submit button

#### Loss Details Screen
- Complete loss information
- Edit/delete options
- Impact on stock display

### 8. Rating & Review Module

#### Rating Screen
- Order selection
- Star rating input
- Comment text field
- Submit rating button

#### Reviews List Screen
- Stock reviews display
- Filter by rating
- User feedback
- Response options (seller)

### 9. Admin Module

#### Validation Dashboard
- Pending multiplicators list
- Pending roles list
- Pending stocks list
- Bulk action buttons

#### User Validation Screen
- User details review
- Document viewer
- Approve/reject buttons
- Rejection reason input
- Email notification toggle

#### Stock Validation Screen
- Stock details review
- Validation criteria checklist
- Approve/reject actions
- Notification system

### 10. Notification Module

#### Notifications List
- Real-time notifications
- Mark as read functionality
- Filter by type
- Clear all option

#### Notification Types
- Order updates
- Stock validations
- New registrations
- System announcements

## BLoC Implementation Structure

### Core BLoCs Required

```dart
// Authentication
AuthBloc
PasswordResetBloc

// User Management
UserBloc
ProfileBloc
MultiplicatorBloc
RoleBloc

// Stock Management
StockBloc
StockListBloc
StockDetailsBloc

// Order Management
OrderBloc
OrderListBloc
OrderDetailsBloc

// Plant & Variety
PlantBloc
VarietyBloc

// Loss Management
LossBloc

// Rating System
RatingBloc

// Admin Functions
AdminValidationBloc
UserValidationBloc
StockValidationBloc

// Notifications
NotificationBloc
```

## Data Models (Dart Classes)

### Core Models
- `User`
- `Multiplicator`
- `MultiplicatorRole`
- `Plant`
- `Variety`
- `Stock`
- `Order`
- `Loss`
- `Rating`
- `Notification`

### Response Models
- `AuthResponse`
- `ApiResponse<T>`
- `PaginatedResponse<T>`
- `ValidationResponse`

## API Service Layer

### Services Required
- `AuthService`
- `UserService`
- `StockService`
- `OrderService`
- `PlantService`
- `VarietyService`
- `LossService`
- `RatingService`
- `AdminService`
- `NotificationService`

## UI Components

### Reusable Widgets
- `CustomAppBar`
- `LoadingWidget`
- `ErrorWidget`
- `EmptyStateWidget`
- `StockCard`
- `OrderCard`
- `UserCard`
- `FilterChips`
- `SearchBar`
- `ImagePicker`
- `DocumentViewer`
- `RatingStars`
- `StatusBadge`
- `ActionButton`
- `FormField`
- `DatePicker`
- `DropdownField`

### Screen Templates
- `BaseScreen`
- `ListScreen`
- `DetailsScreen`
- `FormScreen`
- `DashboardScreen`

## Navigation Structure

```
/
├── /auth
│   ├── /login
│   ├── /register
│   └── /reset-password
├── /dashboard
├── /stocks
│   ├── /list
│   ├── /add
│   └── /details/:id
├── /orders
│   ├── /list
│   ├── /place
│   └── /details/:id
├── /plants
│   ├── /list
│   └── /details/:id
├── /varieties
│   ├── /list
│   ├── /add
│   └── /details/:id
├── /profile
│   ├── /view
│   ├── /edit
│   └── /roles
├── /losses
│   ├── /list
│   └── /add
├── /admin
│   ├── /dashboard
│   ├── /validate-users
│   ├── /validate-stocks
│   └── /validate-roles
└── /notifications
```

## Offline Capabilities

### Local Storage Requirements
- User authentication tokens
- User profile data
- Cached stock listings
- Draft orders
- Offline form data
- App settings

### Sync Strategy
- Background sync when online
- Conflict resolution
- Data versioning
- Queue management for offline actions

## Security Features

### Authentication
- JWT token management
- Automatic token refresh
- Secure storage
- Biometric authentication (optional)

### Data Protection
- Input validation
- XSS prevention
- Secure file upload
- Data encryption for sensitive info

## Performance Optimizations

### Caching Strategy
- Image caching
- API response caching
- Lazy loading
- Pagination implementation

### Memory Management
- Proper BLoC disposal
- Image optimization
- List view optimization
- Background task management

## Accessibility Features

### Screen Reader Support
- Semantic labels
- Navigation hints
- Content descriptions
- Focus management

### Visual Accessibility
- High contrast mode
- Font size scaling
- Color blind friendly design
- Touch target sizing

## Localization Support

### Languages
- French (primary)
- Kirundi (secondary)
- English (optional)

### Localized Content
- UI text
- Error messages
- Date/time formats
- Number formats
- Currency display

## Testing Strategy

### Unit Tests
- BLoC testing
- Service layer testing
- Model validation
- Utility functions

### Widget Tests
- Screen rendering
- User interactions
- Form validation
- Navigation flow

### Integration Tests
- API integration
- Authentication flow
- Complete user journeys
- Offline scenarios

## Development Phases

### Phase 1: Core Features
- Authentication system
- Basic dashboard
- Stock listing
- Order placement

### Phase 2: Management Features
- Stock management
- Order management
- Profile management
- Basic admin functions

### Phase 3: Advanced Features
- Loss tracking
- Rating system
- Advanced admin features
- Notifications

### Phase 4: Optimization
- Performance improvements
- Offline capabilities
- Advanced UI/UX
- Analytics integration

## Technical Requirements

### Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  dio: ^5.3.2
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  go_router: ^12.1.1
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  file_picker: ^6.1.1
  permission_handler: ^11.0.1
  connectivity_plus: ^5.0.1
  local_auth: ^2.1.6
  flutter_secure_storage: ^9.0.0
```

### Development Tools
- Flutter Inspector
- BLoC Inspector
- Network Inspector
- Performance Profiler
- Accessibility Scanner

This comprehensive feature list provides the complete roadmap for developing the Flutter frontend with BLoC architecture for the Seeds Management System.

---

## Instructions for AI Code Generation

### Context for AI Assistant
You are tasked with implementing a Flutter mobile application for the Seeds Management System described above. This is a critical agricultural supply chain management system for Burundi that requires:

1. **Strict adherence to business rules** - The hierarchical seed distribution system must be enforced
2. **Role-based UI/UX** - Different interfaces for Admin, Multiplicators, and Cultivators
3. **Robust state management** - Use Flutter BLoC pattern for all state management
4. **Offline-first approach** - App should work with limited connectivity
5. **Security focus** - Proper JWT handling, input validation, and secure storage
6. **Localization** - Support for French (primary) and Kirundi languages
7. **Accessibility** - Follow Flutter accessibility guidelines

### Implementation Priorities
1. **Authentication system** with role-based routing
2. **Dashboard screens** tailored to each user type
3. **Stock management** with proper business rule validation
4. **Order system** with supply chain hierarchy enforcement
5. **Admin validation workflows** for user and stock approval
6. **Offline capabilities** with proper sync mechanisms

### Code Quality Requirements
- Follow Flutter best practices and conventions
- Implement proper error handling and loading states
- Use dependency injection for services
- Write clean, maintainable, and well-documented code
- Implement proper form validation
- Use responsive design principles
- Follow Material Design 3 guidelines

### Key Technical Considerations
- JWT token management with automatic refresh
- Proper BLoC disposal and memory management
- Image caching and optimization
- File upload with progress indicators
- Real-time notifications
- Data synchronization strategies
- Performance optimization for large lists

When implementing any feature, ensure it aligns with the agricultural business context and maintains the integrity of the seed supply chain management system.
