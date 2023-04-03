@echo off
for %%f in (screens/*.dart) do (
	echo screens\%%f
	type "screens\%%f" | findstr "Scaffold"
	echo.
)