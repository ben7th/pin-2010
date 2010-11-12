module PieUi
  module Convention
    include ActionController::RecordIdentifier

    def last_item_of_objects(object_or_objects)
      [object_or_objects].flatten(1).last
    end
    
    # plural_class_name 是 ActionController::RecordIdentifier 中的方法
    # 根据传入的对象或对象数组，获取目标对象名的可读字符串，用于mplist的classname
    def get_mplist_for_object_classname(object_or_objects)
      case object_or_objects
        when nil
          'unknown'
        else
          plural_class_name(last_item_of_objects(object_or_objects))
      end
    end

    # 根据传入的类或数组获取 页面列表对象的 dom id
    #   传入： Cooking::ApplePie
    #     返回 'cooking_apple_pies'
    #   
    #   传入: [<Book id=23>,Cooking::ApplePie]
    #     返回 book_23_cooking_apple_pies
    #
    #   传入： [<Book id=23>,<Cooking::ApplePie id=19>]
    #     返回 book_23_cooking_apple_pies
    #
    #   传入: [:my,<Book id=23>,Cooking::ApplePie]
    #     返回 my_book_23_cooking_apple_pies
    #   
    # 如果是数组，组装每个部分并用 _ 连接
    def build_ul_id(ul_for)
      case ul_for
        when Class, ActiveRecord::Base, MplistRecord
          plural_class_name(ul_for)
        when Array
          _array_html_id(ul_for)
        else
          raise '传入 mplist 的对象不是 Class, ActiveRecord::Base 或 MplistRecord'
      end
    end

    def _array_html_id(array)
      tmp_arr = array.clone
      last_item = tmp_arr.pop
      part1 = tmp_arr.map{|x| dom_id(x)}*'_'
      part2 = build_ul_id(last_item)
      "#{part1}_#{part2}"
    end
  end

  module MplistPartialMethods
    # 根据 Record 获取对应的模板基准名
    def get_partial_base_name_of_model(model)
      underscore_class_name_of(model).demodulize
    end

    # 根据 Record 获取带有目录信息的模板名
    def get_partial_name_of_model(model)
      get_partial_name_of_model_with_prefix(:mpinfo,model)
    end

    def get_partial_name_of_model_with_prefix(prefix,model)
      "#{underscore_class_name_of(model).pluralize}/parts/#{prefix}_#{get_partial_base_name_of_model(model)}"
    end

    def underscore_class_name_of(model)
      model.class.name.underscore
    end

    def get_sym_of(model)
      get_partial_base_name_of_model(model).to_sym
    end

    def _render_partial(extra)
      case extra[:partial]
      when String
        partial_name = extra[:partial]
        locals = extra[:locals] || {}
        render :partial=>partial_name,:locals=>{}.merge(locals)
      when Array
        prefix = extra[:partial][0]
        model = extra[:partial][1]
        partial_name = get_partial_name_of_model_with_prefix(prefix,model)
        locals = extra[:locals] || {}
        render :partial=>partial_name,:locals=>{get_sym_of(model)=>model}.merge(locals)
      end
    end

  end
end