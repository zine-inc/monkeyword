import PackagePlugin

@main
struct FixtureValidationPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let tool = try context.tool(named: "MonkeywordFixtureCheck")
        let stamp = context.pluginWorkDirectory.appending("FixtureValidation.stamp")
        return [
            .buildCommand(
                displayName: "Validate monkeyword fixtures",
                executable: tool.path,
                arguments: [stamp.string],
                inputFiles: [],
                outputFiles: [stamp]
            )
        ]
    }
}
