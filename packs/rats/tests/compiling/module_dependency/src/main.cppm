export module rats.tests.compiling.module_dependency;
import rats.core.imgui;

namespace rats::tests::compiling::module_dependency
{
    export void Foobar()
    {
        using namespace rats::core::imgui;
        TestClass asdasd { .Foo = 10, .Bar = 20 };
    }
}