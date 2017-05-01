Action<string,string> cmd = (c, args) => {
    StartProcess(c, new ProcessSettings {
            Arguments = args,
            WorkingDirectory = "./HMark.hsproj"
        });
};

Task("Build").Does(() => {
        cmd("cabal", "build");
    });

Task("Run")
    .IsDependentOn("Build")
    .Does(() => {
            cmd("cabal", "run");
        });

var target = Argument("Target", "Default");
RunTarget(target);
