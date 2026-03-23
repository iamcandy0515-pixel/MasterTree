/**
 * Database Types Barrel Export (Choice 3.A)
 * Unified entry point for all types in the module.
 */

export * from "./database.types";
export * from "./common.db";
// Modules are already aggregated in database.types.ts, 
// so we don't need to export * from them if they cause name collisions.
// If specific types are needed, they can be accessed via Database interface or explicit named exports here.

