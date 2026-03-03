# ⚡ Phase 2: Server-Side Load Optimization Plan

## 🎯 Objective

Migrate heavy data processing (deduplication, filtering, pagination) from the Flutter client to the Node.js API server. This will significantly reduce the initial load time and memory usage of the admin app.

## 🛠️ Implementation Steps

### 1. Update `TreeService.getAll` (Backend)

- **File**: `nodejs_admin_api/src/modules/trees/trees.service.ts`
- **Action**: Modify `getAll` to accept query parameters:
    - `page` (number, default 1)
    - `limit` (number, default 20)
    - `search` (string, optional)
    - `category` (string, optional)
- **Logic**:
    - Implement `count` query for total items.
    - Implement `offset` and `limit` for pagination.
    - Add `ilike` filter for `name_kr` or `scientific_name` if `search` is present.
    - Add exact match filter for `category` if present.

### 2. Implement Server-Side Deduplication (Backend)

- **Challenge**: The current client logic merges trees with the same `name_kr` and combines their images. Doing this purely on DB read with pagination is complex because one "logical tree" might be split across pages if rows are distinct.
- **Strategy**:
    - **Option A (Preferred for now)**: Modify the SQL query to `GROUP BY name_kr` and aggregate images using `json_agg` or similar, tailored for Supabase/PostgreSQL.
    - **Refinement**: Since this is an admin app for _managing_ data, maybe we should _show_ duplicates so admins can fix them?
    - **User Intent**: The user wants the "list view" to look clean like the client does now.
    - **Decision**: implementing `GROUP BY` or `DISTINCT ON (name_kr)` logic in the service. simpler: Fetch raw paginated data, but that risks cutting off a group.
    - **Better Approach**: Paginate by _unique names_.
        1. Fetch unique `name_kr` list with pagination (Subquery).
        2. Fetch all trees belonging to those names.
        3. Merge in service layer.

### 3. Update `TreeController.getAll` (Backend)

- **File**: `nodejs_admin_api/src/modules/trees/trees.controller.ts`
- **Action**: Extract `req.query` params and pass to Service.
- **Response Format**:
    ```json
    {
      "data": [...],
      "meta": {
        "total": 105,
        "page": 1,
        "limit": 20,
        "totalPages": 6
      }
    }
    ```

### 4. Verify API

- Use `curl` or browser to test: `GET /api/trees?page=1&limit=5&search=소나무`

---
