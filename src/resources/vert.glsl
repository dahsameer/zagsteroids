#version 460 core
layout(location = 0) in vec2 aPos;

uniform vec2  uTranslation;
uniform float uRotation;
uniform vec2  uResolution;
uniform float uScale;

void main()
{
  float c = cos(uRotation);
  float s = sin(uRotation);
  vec2 rotated = vec2(aPos.x * c - aPos.y * s,
                      aPos.x * s + aPos.y * c);
  vec2 world = rotated * uScale + uTranslation;
  vec2 ndc = (world / uResolution) * 2.0 - 1.0;
  gl_Position = vec4(ndc.x, -ndc.y, 0.0, 1.0);
}