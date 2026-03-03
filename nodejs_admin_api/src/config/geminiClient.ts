import axios from "axios";

export async function geminiPredict(imageUrl: string) {
    const apiKey = process.env.GEMINI_KEY;

    try {
        // 1. Fetch image and convert to Base64
        const imageResponse = await axios.get(imageUrl, {
            responseType: "arraybuffer",
        });
        const base64Image = Buffer.from(imageResponse.data).toString("base64");
        const mimeType = imageResponse.headers["content-type"] || "image/jpeg";

        // 2. Call Gemini 2.0 Flash API (v1beta)
        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
            {
                contents: [
                    {
                        parts: [
                            {
                                text: "이 나무는 어떤 수종인가? (Provide species name and brief description in Korean)",
                            },
                            {
                                inline_data: {
                                    mime_type: mimeType,
                                    data: base64Image,
                                },
                            },
                        ],
                    },
                ],
            },
        );

        return response.data;
    } catch (error: any) {
        console.error(
            "Gemini API Error:",
            error.response?.data || error.message,
        );
        throw new Error("Failed to process image with Gemini AI");
    }
}

export async function geminiGenerateText(prompt: string) {
    const apiKey = process.env.GEMINI_KEY;

    try {
        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
            {
                contents: [
                    {
                        parts: [
                            {
                                text: prompt,
                            },
                        ],
                    },
                ],
                // We can enforce JSON response with system_instruction or response_mime_type
                generationConfig: {
                    responseMimeType: "application/json",
                },
            },
        );

        const responseText =
            response.data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!responseText) {
            throw new Error("No response generated from Gemini.");
        }

        return JSON.parse(responseText);
    } catch (error: any) {
        console.error(
            "Gemini Text API Error:",
            error.response?.data || error.message,
        );
        throw new Error("Failed to generate text with Gemini AI");
    }
}

export async function geminiExtractFromPdfBuffer(
    pdfBase64: string,
    prompt: string,
) {
    const apiKey = process.env.GEMINI_KEY;

    try {
        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
            {
                contents: [
                    {
                        parts: [
                            { text: prompt },
                            {
                                inline_data: {
                                    mime_type: "application/pdf",
                                    data: pdfBase64,
                                },
                            },
                        ],
                    },
                ],
                generationConfig: {
                    responseMimeType: "application/json",
                },
            },
        );

        const responseText =
            response.data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!responseText) {
            throw new Error("No response generated from Gemini.");
        }

        return JSON.parse(responseText);
    } catch (error: any) {
        const errorMsg = error.response?.data?.error?.message || error.message;
        console.error("Gemini PDF API Error:", errorMsg);
        throw new Error(`Gemini API Error: ${errorMsg}`);
    }
}

/**
 * Generates text embeddings using Gemini text-embedding-004
 */
export async function geminiEmbedText(text: string): Promise<number[]> {
    const apiKey = process.env.GEMINI_KEY;
    try {
        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=${apiKey}`,
            {
                content: {
                    parts: [{ text: text }],
                },
                outputDimensionality: 768,
            },
        );

        const embedding = response.data.embedding?.values;
        if (!embedding) {
            throw new Error("No embedding values returned from Gemini.");
        }
        return embedding;
    } catch (error: any) {
        console.error(
            "Gemini Embedding API Error:",
            error.response?.data || error.message,
        );
        throw new Error("Failed to generate embedding with Gemini AI");
    }
}
