# Database Architecture

This document outlines the database structure for the LLM Mania application.

## Entity Relationship Diagram

```mermaid
erDiagram
    USER {
        UUID id PK
        STRING first_name
        STRING last_name
        STRING email
        STRING password_digest
        STRING gender
        STRING lang
        BOOLEAN active
        UUID current_role_id FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    ROLE {
        UUID id PK
        STRING name
        STRING description
        BOOLEAN active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    USER_ROLE {
        UUID id PK
        UUID user_id FK "unique with role_id"
        UUID role_id FK "unique with user_id"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }
    
    SUBSCRIPTION {
        UUID id PK
        STRING name
        INTEGER max_llm_requests_per_day
        INTEGER priority
        INTEGER max_prompt_length
        BOOLEAN private_prompts_allowed
        BOOLEAN active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    SUBSCRIPTION_HISTORY {
        UUID id PK
        UUID user_id FK
        UUID subscription_id FK
        DATE start_date
        DATE end_date
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    PROMPT {
        UUID id PK
        UUID user_id FK
        TEXT content
        BOOLEAN private
        STRING status
        BOOLEAN hidden
        BOOLEAN flagged
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    PROMPT_REPORT {
        UUID id PK
        UUID prompt_id FK "unique with user_id"
        UUID user_id FK "unique with prompt_id"
        STRING reason
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    LLM {
        UUID id PK
        STRING name
        STRING ollama_model
        INTEGER size
        BOOLEAN active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    LLM_JOB {
        UUID id PK
        UUID prompt_id FK
        UUID llm_id FK
        INTEGER priority
        INTEGER position
        STRING status
        INTEGER response_time_ms
        TEXT response
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    RATING {
        UUID id PK
        UUID user_id FK "unique with llm_job_id"
        UUID llm_job_id FK "unique with user_id"
        INTEGER score
        TEXT comment
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    SUBSCRIPTION_LLM {
        UUID id PK
        UUID subscription_id FK "unique with llm_id"
        UUID llm_id FK "unique with subscription_id"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    %% Relationships
    USER ||--|{ PROMPT : has
    USER ||--|{ PROMPT_REPORT : can_report
    USER ||--|{ SUBSCRIPTION_HISTORY : has
    USER ||--|{ RATING : gives
    USER ||--|| ROLE : current_role
    USER ||--|{ USER_ROLE : has
    USER_ROLE }|--|| ROLE : belongs_to

    SUBSCRIPTION ||--|{ SUBSCRIPTION_HISTORY : has
    SUBSCRIPTION ||--|{ SUBSCRIPTION_LLM : supports

    SUBSCRIPTION_HISTORY }|--|| SUBSCRIPTION : tracks
    SUBSCRIPTION_HISTORY }|--|| USER : belongs_to


    PROMPT ||--|{ LLM_JOB : generates
    PROMPT ||--|{ PROMPT_REPORT : can_be_reported

    PROMPT_REPORT }|--|| PROMPT : reports
    PROMPT_REPORT }|--|| USER : submitted_by

    LLM ||--|{ LLM_JOB : processes
    LLM ||--|{ SUBSCRIPTION_LLM : supported_by

    LLM_JOB ||--|| PROMPT : belongs_to
    LLM_JOB ||--|| LLM : uses
    LLM_JOB ||--|{ RATING : has

    RATING }|--|| LLM_JOB : rates
    RATING }|--|| USER : given_by

    SUBSCRIPTION_LLM }|--|| SUBSCRIPTION : links
    SUBSCRIPTION_LLM }|--|| LLM : links
```

## Entity Descriptions

### User
Represents application users with their personal information and subscription status.
- `gender`: Enum (male, female, other)
- `role`: Enum (user, admin)
- `lang`: String (en, de) - User's preferred interface language

### Subscription
Defines different subscription tiers with their associated features and limitations.
- `name`: String - Name of the subscription plan
- `description`: String - Description of the subscription plan
- `max_llm_requests_per_day`: Integer - Maximum number of LLM requests allowed per day
- `priority`: Integer - Priority level for request processing
- `max_prompt_length`: Integer - Maximum allowed prompt length
- `price_cents`: Integer - Price in cents
- `private_prompts_allowed`: Boolean - Whether private prompts are allowed
- `active`: Boolean - Whether the subscription is active

### Subscription History
Tracks the history of user subscriptions over time.

### Daily Usage
Monitors user's daily LLM request usage for quota management.

### Prompt
Stores user prompts sent to LLM.
- `private`: Replaces `is_private` to follow Rails boolean naming conventions
- `status`: Enum (waiting, in_queue, processing, completed, failed)

### Prompt Report
Handles user reports for inappropriate prompts.
- `user_id`: Nullable foreign key
- `reason`: Enum (spam, offensive, nsfw, other)

### LLM
Defines available LLM and their configurations.
- `ollama_model`: Name of the model in Ollama (e.g., "llama2", "mistral", etc.)
- `size`: Size of the model in billions of parameters

### LLM Job
Manages the processing of prompts by LLMs.
- `status`: Enum (queued, processing, completed, failed)
- `response`: Text - The response generated by the LLM

### Rating
Tracks user ratings and feedback for LLM responses.
- `score`: Integer (1-5) - User rating score
- `comment`: Text - User feedback comment

### Subscription LLM
Links subscriptions with their available LLM.
- `subscription_id`: UUID - Reference to the subscription
- `llm_id`: UUID - Reference to the LLM
- Represents a many-to-many relationship between subscriptions and LLM
- Determines which LLM are available for each subscription tier 