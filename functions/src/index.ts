import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import vision from "@google-cloud/vision";

admin.initializeApp();

const client = new vision.ImageAnnotatorClient();

export const extractTextFromImage = functions.https.onCall(
    async (request) => {
        const imageUrl = request.data?.imageUrl;
        if (!imageUrl) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Missing image URL"
            );
        }

        try {
            const [result] = await client.documentTextDetection(imageUrl);
            const annotation = result.fullTextAnnotation;

            const blocks = [];
            if (annotation?.pages) {
                for (const page of annotation.pages) {
                    for (const block of page.blocks ?? []) {
                        const blockText = block.paragraphs
                                ?.map(p => p.words?.map(w => w.symbols?.map(s => s.text).join('')).join(' '))
                                .join(' ')
                            ?? '';
                        const confidence = block.confidence ?? 1.0;
                        const boundingBox = block.boundingBox?.vertices ?? [];
                        blocks.push({ text: blockText, confidence, boundingBox });
                    }
                }
            }

            const fullText = annotation?.text ?? '';

            return { fullText, blocks };

        } catch (error: any) {
            console.error("Vision API error:", error);
            throw new functions.https.HttpsError(
                "internal",
                "Vision API error",
                error.message
            );
        }
    }
);