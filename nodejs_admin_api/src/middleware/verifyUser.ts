import { Request, Response, NextFunction, RequestHandler } from "express";
import { supabase } from "../config/supabaseClient";

export const verifyUser: RequestHandler = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        res.status(401).json({ error: "No token provided" });
        return;
    }

    const token = authHeader.replace("Bearer ", "");

    /** Supabase JWT Validation */
    const {
        data: { user },
        error,
    } = await supabase.auth.getUser(token);

    if (error || !user) {
        res.status(401).json({ error: "Invalid or expired token" });
        return;
    }

    // Attach user to request object
    (req as any).user = user;
    next();
};
