#include <windows.h>
#include <dwrite.h>
#include <stdio.h>
#include <math.h>

#pragma comment(lib, "dwrite.lib")

int main() {
    IDWriteFactory* dwrite;
    DWriteCreateFactory(DWRITE_FACTORY_TYPE_SHARED, __uuidof(IDWriteFactory), (IUnknown**)&dwrite);
    IDWriteTextFormat* fmt;
    
    // Test Cascadia Mono
    dwrite->CreateTextFormat(L"Cascadia Mono", NULL, DWRITE_FONT_WEIGHT_REGULAR, DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, 10.0f, L"en-US", &fmt);
    IDWriteTextLayout* layout;
    dwrite->CreateTextLayout(L"M", 1, fmt, 1000.0f, 1000.0f, &layout);
    DWRITE_TEXT_METRICS metrics;
    layout->GetMetrics(&metrics);
    printf("Cascadia Mono 10pt (M): height=%f layoutHeight=%f\n", metrics.height, metrics.layoutHeight);
    
    // Check line spacing DWrite API
    DWRITE_LINE_SPACING_METHOD method;
    FLOAT spacing, baseline;
    fmt->GetLineSpacing(&method, &spacing, &baseline);
    printf("Cascadia Line Spacing: %d, spacing=%f, baseline=%f\n", method, spacing, baseline);
    
    fmt->Release(); layout->Release();

    return 0;
}
