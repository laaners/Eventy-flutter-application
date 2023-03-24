@echo off
for %%f in (screens/*.dart) do (
	echo %%f
	type "%%f" | findstr "import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';"
	echo.
)