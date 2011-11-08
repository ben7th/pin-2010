package com.mindpin.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import com.mindpin.Logic.AccountManager;
import com.mindpin.base.utils.FileDirs;
import com.mindpin.beans.Collection;

public class CollectionsCache {

	public static void save(String collections) {
		int user_id = AccountManager.current_user().user_id;
		if(user_id == 0){
			return;
		}
		
		try {
			FileUtils.writeStringToFile(get_collections_file(user_id), collections);
		}catch(IOException e){
			e.printStackTrace();
		}
	}
	
	public static void delete(int user_id){
		File file = get_collections_file(user_id);
		file.delete();
	}
	
	public static ArrayList<Collection> get_current_user_collection_list(){
		ArrayList<Collection> list = new ArrayList<Collection>();
		int user_id = AccountManager.current_user().user_id;
		if(user_id == 0){
			return list;
		}
		
		try {
			String json_str = IOUtils.toString(new FileInputStream(get_collections_file(user_id)));
			list = Collection.build_list_by_json(json_str);
			return list;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return list;
		} catch (IOException e) {
			e.printStackTrace();
			return list;
		}
	}
	

	private static File get_collections_file(int user_id){
		return new File(FileDirs.mindpin_user_cache_dir(user_id), "collections.json");
	}

}
