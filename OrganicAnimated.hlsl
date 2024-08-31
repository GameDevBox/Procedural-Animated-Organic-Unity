void AnimatedOrganic_float(bool autoColor, float scale, float scaleMultiplicationStep,
                           float RotationStep, float UVAnimationSpeed, float RippleStrength,
                           float RippleMaxFrequency, float RippleSpeed, float Brightness,
                           float Iterations, float2 uv, float time, out float output,
                           out float4 color)
{
    // Initialize the output variables: output controls the visual intensity, color holds the final RGB value
    output = 0.0;
    color = float4(0.0, 0.0, 0.0, 1.0); // Initialize color to black with full alpha

    // Normalize and center UV coordinates to range [-1, 1] for radial calculations
    uv = float2(uv - 0.5) * 2.0;

    // Calculate a radial gradient based on the UV distance from the center
    float invertedRadialGradient = pow(length(uv), 2.0);

    // Distance from the center, used for scaling effects over distance
    float d = dot(uv, uv);

    // Animate UVs over time to create a dynamic texture effect
    float uvTime = time * UVAnimationSpeed;

    // Generate a time-based noise strength factor for fluctuating animation
    float noiseStrength = 0.5 + 0.5 * sin(time * 0.5);

    // Compute a base scale factor that changes over time for pulsating effects
    float scaleBase = 1.5 + sin(time * 0.2) * 0.5;

    // Factor used to simulate depth fading effect based on distance from center
    float depthFactor = 1.0 / (1.0 + d);
    
    // Create ripple effects modulated by time and distance from the center
    float ripples = sin((time * RippleSpeed) - (invertedRadialGradient * RippleMaxFrequency)) * RippleStrength;

    // Precompute the rotation matrix for UV transformation using the given rotation step
    float2x2 rotationMatrix = float2x2(cos(RotationStep), -sin(RotationStep), sin(RotationStep), cos(RotationStep));

    // Initialize loop variables for iterative distortion of UVs
    float2 n = float2(0.0, 0.0); // Vector offset applied in each iteration
    float i = 0.0; // Iteration counter
    float2 q = 0.0; // Resulting vector from combined transformations

    // Perform iterative modifications to simulate organic distortion effects
    for (i = 0.0; i < Iterations; i++)
    {
        // Apply rotation to UV coordinates to create a swirling effect
        uv = mul(rotationMatrix, uv);
        n = mul(rotationMatrix, n); // Apply the same rotation to offset vector
        
        // Compute the animated UV coordinates with current scale and time modulation
        float2 animatedUV = (uv * scale) + uvTime;

        // Combine animated UV, ripples, and offset to create dynamic texture coordinates
        q = animatedUV + ripples + i + n;

        // Accumulate the output based on cosine of modified coordinates for smooth transitions
        output += dot(cos(q) / scale, float2(1.0, 1.0) * Brightness);

        // Update offset vector with sine of current coordinates to add non-linear distortion
        n -= sin(q);

        // Gradually reduce scale to enhance the detail and complexity in subsequent iterations
        scale *= scaleMultiplicationStep;
    }
    
    // Conditional auto-coloring based on the generated output value and time-based variation
    if (autoColor)
    {
        // Compute RGB color values using sine and cosine functions for dynamic color shifts
        float r = 0.5 + 0.5 * sin(output + time * 1.5); // Red channel oscillation
        float g = 0.5 + 0.5 * cos(output + time * 1.7); // Green channel oscillation
        float b = 0.5 + 0.5 * sin(output + time * 2.0); // Blue channel oscillation

        // Assign computed RGB values to the color output with full opacity
        color.rgb = float3(r, g, b);
        color.a = 1.0; // Ensuring the color is fully opaque
    }
}
