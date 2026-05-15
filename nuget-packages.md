**To build a .NET project using only local packages (no internet/nuget.org),** you have several reliable options. The most common scenarios are offline builds or using your own local `.nupkg` files.

### 1. Quickest: Use the Local Global Packages Cache as a Source (Recommended for Offline)

.NET already caches packages locally in the **global-packages** folder.

1. Find your local cache locations:
   ```bash
   dotnet nuget locals all --list
   ```
   Typical output:
   ```
   global-packages: C:\Users\YourName\.nuget\packages\
   ```

2. Add the global packages folder as a NuGet source:
   ```bash
   dotnet nuget add source "C:\Users\YourName\.nuget\packages\" --name local-cache
   ```

3. Build/restore using only local sources:
   ```bash
   dotnet restore --source "C:\Users\YourName\.nuget\packages\" --no-cache
   dotnet build --no-restore
   ```
   Or combine:
   ```bash
   dotnet build --source "C:\Users\YourName\.nuget\packages\" --no-cache
   ```

**Tip**: Use `--ignore-failed-sources` if you have other sources configured but want to skip failures.

### 2. Use a Dedicated Local Folder Feed (Best for Your Own Packages)

Create a folder with your `.nupkg` files and treat it as a feed.

```bash
# Create folder
mkdir LocalNuGetFeed

# Copy your packages there (or build them with dotnet pack)
dotnet pack MyLibrary -o ../LocalNuGetFeed

# Add as source
dotnet nuget add source ./LocalNuGetFeed --name LocalFeed
```

Then restore/build:
```bash
dotnet restore --source ./LocalNuGetFeed
dotnet build --no-restore
```

### 3. Control Sources with a `nuget.config` File (Most Reliable for Teams/CI)

Create a `nuget.config` in your solution root:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <!-- Disable default nuget.org -->
    <clear />
    <add key="LocalFeed" value="C:\Path\To\LocalNuGetFeed" />
    <add key="LocalCache" value="C:\Users\YourName\.nuget\packages\" />
  </packageSources>
  
  <disabledPackageSources>
    <add key="nuget.org" value="true" />
  </disabledPackageSources>
</configuration>
```

Use it:
```bash
dotnet restore --configfile nuget.config
dotnet build --no-restore
```

### 4. Other Useful Flags

| Flag                        | Purpose |
|----------------------------|---------|
| `--no-restore`             | Skip restore during build (use after successful restore) |
| `--no-cache` / `--no-http-cache` | Don't use HTTP cache |
| `--source <path>` (multiple) | Override all sources |
| `--ignore-failed-sources`  | Continue even if some sources fail |
| `--packages <dir>`         | Use a specific packages directory |

### 5. For CI/Build Servers (Completely Offline)

- Pre-populate the global packages cache or a local feed.
- Use the `nuget.config` approach above.
- Run with:
  ```bash
  dotnet restore --configfile nuget.config --source "path/to/local" --no-cache
  ```

### Bonus: Project References Instead of Packages (Development)

For local development of dependent libraries, use **project references** instead of NuGet packages:

```xml
<ItemGroup>
  <ProjectReference Include="..\MyLibrary\MyLibrary.csproj" />
</ItemGroup>
```

This avoids packaging altogether during dev.

This setup ensures **dotnet build** only looks at local packages/folders and never tries to hit the internet. Let me know your exact scenario (e.g., own packages, fully offline CI, etc.) if you need more tailored commands!



# Publishing Package to Local Sources

How to publish a `.nupkg` to a Local repository.

```bash
dotnet nuget push microsft.netcore.app.host.win-x64.9.0.16.nupkg --source LocalNuget
```