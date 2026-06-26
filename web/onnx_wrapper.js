let ortSession;

async function initEmotionModel(modelUrl) {
    try {
        console.log("Loading ONNX model from: " + modelUrl);
        ortSession = await ort.InferenceSession.create(modelUrl);
        console.log("ONNX model loaded successfully!");
        return true;
    } catch (e) {
        console.error("Failed to load ONNX model", e);
        return false;
    }
}

async function predictEmotionModel(inputArray) {
    if (!ortSession) {
        throw new Error("Model is not initialized!");
    }
    
    // Create tensor: [1, 3, 224, 224] matching our image dimensions
    const tensor = new ort.Tensor('float32', inputArray, [1, 3, 224, 224]);
    const feeds = { input: tensor };
    
    // Run inference
    const results = await ortSession.run(feeds);
    const outputTensor = results[ortSession.outputNames[0]];
    
    // Return standard array
    return Array.from(outputTensor.data);
}

// Attach to window so Dart can access them easily
window.initEmotionModel = initEmotionModel;
window.predictEmotionModel = predictEmotionModel;
