package com.assaultcube.android;

import android.content.res.AssetManager;
import android.os.Bundle;
import android.util.Log;

import org.libsdl.app.SDLActivity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class AssaultCubeActivity extends SDLActivity {
    private static final String TAG = "AssaultCube";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Extract assets before SDL initializes
        extractAssets();
        super.onCreate(savedInstanceState);
    }

    private void extractAssets() {
        String internalPath = getFilesDir().getAbsolutePath();
        String destPath = internalPath + "/packages";

        // Skip if already extracted
        if (new File(destPath + "/misc/notexture.jpg").exists()) {
            Log.i(TAG, "Assets already extracted");
            return;
        }

        Log.i(TAG, "Extracting game assets to " + destPath + "...");
        try {
            AssetManager assetManager = getAssets();
            extractDir(assetManager, "packages", destPath);
            extractDir(assetManager, "config", internalPath + "/config");
            Log.i(TAG, "Asset extraction complete");
        } catch (IOException e) {
            Log.e(TAG, "Failed to extract assets: " + e.getMessage());
        }
    }

    private void extractDir(AssetManager assetManager, String assetPath, String destPath) throws IOException {
        String[] items = assetManager.list(assetPath);
        if (items == null || items.length == 0) {
            // It's a file, copy it
            copyFile(assetManager, assetPath, destPath);
        } else {
            // It's a directory, recurse
            new File(destPath).mkdirs();
            for (String item : items) {
                extractDir(assetManager, assetPath + "/" + item, destPath + "/" + item);
            }
        }
    }

    private void copyFile(AssetManager assetManager, String assetPath, String destPath) throws IOException {
        File destFile = new File(destPath);
        if (destFile.exists()) return; // Skip existing files

        destFile.getParentFile().mkdirs();

        InputStream in = assetManager.open(assetPath);
        OutputStream out = new FileOutputStream(destFile);
        byte[] buffer = new byte[8192];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }
        out.flush();
        out.close();
        in.close();
    }
}
