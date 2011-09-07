package com.mindpin.cache;

import java.io.File;
import java.io.IOException;
import org.apache.commons.io.FileUtils;
import android.os.Environment;

public class CollectionsCache {

	public static void save(String collections) {
		try {
			FileUtils.writeStringToFile(get_collections_file(), collections);
		}catch(IOException e){
			e.printStackTrace();
		}
	}

	private static File get_collections_file() {
		File cache_dir = new File(Environment.getExternalStorageDirectory()
				.getPath() + "/mindpin/cache/");
		if (!cache_dir.exists()) {
			cache_dir.mkdirs();
		}
		return new File(cache_dir,"collections.json");
	}

}
