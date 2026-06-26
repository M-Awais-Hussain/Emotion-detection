// face_wrapper.js

let isFaceModelLoaded = false;

async function ensureFaceModelLoaded() {
    if (isFaceModelLoaded) return;
    try {
        console.log("Loading face-api tiny_face_detector model from CDN...");
        // Load Tiny Face Detector from vladmandic CDN
        await faceapi.nets.tinyFaceDetector.loadFromUri('https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/');
        isFaceModelLoaded = true;
        console.log("Face model loaded successfully.");
    } catch (e) {
        console.error("Failed to load face model:", e);
        throw e;
    }
}

/**
 * Detects a face and returns bounding box
 * @param {Uint8Array} imageBytes 
 * @returns {Promise<number[]|null>} Array of [x, y, width, height] or null
 */
async function detectFaceBoundingBox(imageBytes) {
    await ensureFaceModelLoaded();

    return new Promise((resolve, reject) => {
        try {
            // Convert byte array to Blob then to HTMLImageElement
            const blob = new Blob([imageBytes], { type: 'image/jpeg' });
            const url = URL.createObjectURL(blob);
            const img = new Image();
            
            img.onload = async () => {
                try {
                    // Detect single face using tiny face detector
                    const detection = await faceapi.detectSingleFace(img, new faceapi.TinyFaceDetectorOptions());
                    URL.revokeObjectURL(url);
                    
                    if (!detection) {
                        console.log("No face detected.");
                        resolve(null);
                        return;
                    }

                    const box = detection.box;
                    // Return [x, y, width, height]
                    resolve([box.x, box.y, box.width, box.height]);
                } catch (e) {
                    URL.revokeObjectURL(url);
                    reject(e);
                }
            };
            
            img.onerror = (e) => {
                URL.revokeObjectURL(url);
                reject(new Error("Failed to load image for face detection"));
            };
            
            img.src = url;
        } catch (e) {
            reject(e);
        }
    });
}

// Attach to window object for Dart JS interop
window.detectFaceBoundingBox = detectFaceBoundingBox;
