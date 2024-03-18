using UnrealBuildTool;

public class Template : ModuleRules
{
	public Template(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new[] { "Core", "CoreUObject", "Engine", "InputCore" });

		PrivateDependencyModuleNames.AddRange(new string[] { });

		// 如果使用的是 Slate UI，请取消注释
		// PrivateDependencyModuleNames.AddRange(new[] { "Slate", "SlateCore" });

		// 如果使用在线功能，请取消注释
		// 要包含 OnlineSubsystemSteam，请将其添加到 uproject 文件的插件部分，并将 Enabled 属性设置为 true
		// PrivateDependencyModuleNames.Add("OnlineSubsystem");
	}
}