#include "_.h"

namespace rats::core::imgui
{
    using namespace ImGui;

    void Test()
    {
        Begin("stuff");
            Text("Hello");
        End();
    }
}