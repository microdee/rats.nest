module;
#include "imgui.h"
export module rats.core.imgui;

/**
 * Very common ImGui functionalities
 */
namespace rats::core::imgui
{
    using namespace ImGui;

    export void Test()
    {
        Begin("stuff");
            Text("Hello");
        End();
    }
}