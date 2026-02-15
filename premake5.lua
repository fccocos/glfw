project "GLFW"
	kind "StaticLib"
	language "C"
	staticruntime "off"
	warnings "off"

	targetdir ("bin/" .. outputdir .. "/%{prj.name}")
	objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

	-- 关键新增：GLFW 静态编译必需定义 + 禁用 assert 消除 _wassert
	defines {
		"GLFW_BUILD_STATIC",  -- 静态库编译标记（核心）
		"_CRT_SECURE_NO_WARNINGS"  -- 禁用 MSVC 安全警告，避免符号替换
	}

	-- 关键新增：Windows 系统库（GLFW 依赖）
	filter "system:windows"
		links {
			"user32",    -- 窗口管理
			"gdi32",     -- 图形设备
			"opengl32",  -- OpenGL
			"kernel32",  -- 内核功能
			"shell32",   -- Shell 操作
			"ole32",     -- COM 组件
			"oleaut32",  -- OLE 自动化
			"imm32",     -- 输入法
			"winmm",     -- 多媒体/定时器
			"advapi32"   -- 高级 API
		}

	files {
		"include/GLFW/glfw3.h",
		"include/GLFW/glfw3native.h",
		"src/glfw_config.h",
		"src/context.c",
		"src/init.c",
		"src/input.c",
		"src/monitor.c",

		"src/null_init.c",
		"src/null_joystick.c",
		"src/null_monitor.c",
		"src/null_window.c",

		"src/platform.c",
		"src/vulkan.c",
		"src/window.c",
	}

	filter "system:linux"
		pic "On"
		systemversion "latest"
		
		files
		{
			"src/x11_init.c",
			"src/x11_monitor.c",
			"src/x11_window.c",
			"src/xkb_unicode.c",
			"src/posix_module.c",
			"src/posix_time.c",
			"src/posix_thread.c",
			"src/posix_module.c",
			"src/glx_context.c",
			"src/egl_context.c",
			"src/osmesa_context.c",
			"src/linux_joystick.c"
		}

		defines
		{
			"_GLFW_X11"
		}

	filter "system:macosx"
		pic "On"

		files
		{
			"src/cocoa_init.m",
			"src/cocoa_monitor.m",
			"src/cocoa_window.m",
			"src/cocoa_joystick.m",
			"src/cocoa_time.c",
			"src/nsgl_context.m",
			"src/posix_thread.c",
			"src/posix_module.c",
			"src/osmesa_context.c",
			"src/egl_context.c"
		}

		defines
		{
			"_GLFW_COCOA"
		}

	filter "system:windows"
		systemversion "latest"
		staticruntime "Off"

		files
		{
			"src/win32_init.c",
			"src/win32_joystick.c",
			"src/win32_module.c",
			"src/win32_monitor.c",
			"src/win32_time.c",
			"src/win32_thread.c",
			"src/win32_window.c",
			"src/wgl_context.c",
			"src/egl_context.c",
			"src/osmesa_context.c"
		}

		defines 
		{ 
			"_GLFW_WIN32",
			"_CRT_SECURE_NO_WARNINGS"
		}

	filter "configurations:Debug"
		runtime "Debug"
		-- runtimechecks "On"  -- 注释保留，不影响核心功能
		symbols "on"
		defines { 
			"_DEBUG"
		}

	filter { "system:windows", "configurations:Debug-AS" }	
		runtime "Debug"
		symbols "on"
		sanitize { "Address" }
		--flags { "NoRuntimeChecks", "NoIncrementalLink" }
		runtimechecks "Off"       -- 替代废弃的 NoRuntimeChecks
        incrementallink "Off"     -- 替代废弃的 NoIncrementalLink

	filter "configurations:Release"
		runtime "Release"
		optimize "speed"
		defines { "NDEBUG" }  -- 补充：Release 模式显式禁用 assert

    filter "configurations:Dist"
		runtime "Release"
		optimize "speed"
        symbols "off"
		defines { "NDEBUG" }  -- 补充：Dist 模式禁用 assert