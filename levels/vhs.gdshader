shader_type canvas_item;

// IMPORTANTE: O filter_nearest deixa os pixels duros/crocantes. 
// Sem ele, a Godot vai tentar borrar e estragar o efeito retrô.
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// --- Parâmetros Ajustáveis no Inspetor ---

// Controla o "tamanho" do pixel. Valores maiores = resolução menor (mais quadriculado)
uniform float pixel_size : hint_range(1.0, 16.0) = 3.0; 

// Limita a quantidade de cores na tela (Efeito PS1 / Color Banding)
uniform float color_depth : hint_range(1.0, 256.0) = 32.0;

// Scanlines e ruído super sutis só para dar uma textura "suja"
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.02;
uniform float grain_intensity : hint_range(0.0, 1.0) = 0.03;

// Função simples de ruído
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // 1. PIXELIZAÇÃO (Redução de Resolução)
    // Pegamos a resolução real da tela
    vec2 resolution = vec2(textureSize(screen_texture, 0));
    
    // Calculamos uma nova UV baseada no "tamanho do pixel" que definimos
    vec2 pixelated_uv = floor(SCREEN_UV * resolution / pixel_size) / (resolution / pixel_size);

    // Lemos a textura usando a UV pixelada (o filter_nearest lá em cima garante que não borre)
    vec3 color = texture(screen_texture, pixelated_uv).rgb;

    // 2. POSTERIZAÇÃO (Limitação de Cores)
    // Multiplicamos, arredondamos e dividimos para forçar a imagem a usar menos tons de cor
    color = floor(color * color_depth) / color_depth;

    // 3. SUJEIRA SUTIL (Ruído + Scanlines)
    // Mantivemos bem fraco só para a imagem não parecer "limpa" demais
    float noise = random(pixelated_uv * TIME);
    color += noise * grain_intensity;

    float scanline = sin(SCREEN_UV.y * resolution.y * PI);
    scanline = (scanline + 1.0) / 2.0;
    color -= scanline * scanline_intensity;

    COLOR = vec4(color, 1.0);
}