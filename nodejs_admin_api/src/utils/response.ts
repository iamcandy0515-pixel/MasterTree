import { Response } from "express";

export const sendResponse = <T>(
    res: Response,
    statusCode: number,
    message: string,
    data?: T,
): void => {
    res.status(statusCode).json({
        success: statusCode >= 200 && statusCode < 300,
        message,
        data,
    });
};

export const successResponse = <T>(
    res: Response,
    data: T,
    message: string = "Success",
    statusCode: number = 200,
): void => {
    sendResponse(res, statusCode, message, data);
};

export const errorResponse = (
    res: Response,
    message: string = "Internal Server Error",
    statusCode: number = 500,
): void => {
    sendResponse(res, statusCode, message);
};
