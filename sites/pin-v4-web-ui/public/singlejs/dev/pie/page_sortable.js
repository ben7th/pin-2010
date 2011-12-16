pie.sortable_observer = Class.create({
  initialize: function(element, observer) {
    this.element   = $(element);
    this.observer  = observer;
    this.lastValue = pie.sortable.serialize(this.element);
  },

  onStart: function() {
    this.lastValue = pie.sortable.serialize(this.element);
  },

  onEnd: function() {
    //songliang add..
    pie.sortable._placeholder.insert({Before:pie.sortable.dragging})
    pie.sortable._placeholder.hide();
    $(pie.sortable.dragging).setStyle({'position':'relative',left:'',top:'',height:'',width:''});
    pie.sortable.is_dragging = false;

    pie.sortable.unmark();
    if(this.lastValue != pie.sortable.serialize(this.element))
      this.observer(this.element)
  }
});

pie.sortable = {
  SERIALIZE_RULE: /^[^_\-](?:[A-Za-z0-9\-\_]*)[_](.*)$/,

  sortables: { },

  _findRootElement: function(element) {
    while (element.tagName.toUpperCase() != "BODY") {
      if(element.id && pie.sortable.sortables[element.id]) return element;
      element = element.parentNode;
    }
  },

  options: function(element) {
    element = pie.sortable._findRootElement($(element));
    if(!element) return false;
    return pie.sortable.sortables[element.id];
  },

  destroy: function(element){
    element = $(element);
    var s = pie.sortable.sortables[element.id];

    if(s) {
      Draggables.removeObserver(s.element);
      s.droppables.each(function(d){ Droppables.remove(d) });
      s.draggables.invoke('destroy');

      delete pie.sortable.sortables[s.element.id];
    }
  },

  create: function(element) {
    element = $(element);
    var options = Object.extend({
      element:     element,
      tag:         'li',       // assumes li children, override with tag: 'tagname'
      dropOnEmpty: false,
      tree:        false,
      treeTag:     'ul',
      overlap:     'vertical', // one of 'vertical', 'horizontal'
      constraint:  'vertical', // one of 'vertical', 'horizontal', false
      containment: element,    // also takes array of elements (or id's); or false
      handle:      false,      // or a CSS class
      only:        false,
      delay:       0,
      hoverclass:  null,
      ghosting:    false,
      quiet:       false,
      scroll:      false,
      scrollSensitivity: 20,
      scrollSpeed: 15,
      format:      this.SERIALIZE_RULE,

      // these take arrays of elements or ids and can be
      // used for better initialization performance
      elements:    false,
      handles:     false,

      onChange:    Prototype.emptyFunction,
      onUpdate:    Prototype.emptyFunction
    }, arguments[1] || { });

    // clear any old sortable with same element
    this.destroy(element);

    // build options for the draggables
    var options_for_draggable = {
      revert:      false, //modified by songliang
      quiet:       options.quiet,
      scroll:      options.scroll,
      scrollSpeed: options.scrollSpeed,
      scrollSensitivity: options.scrollSensitivity,
      delay:       options.delay,
      ghosting:    options.ghosting,
      constraint:  options.constraint,
      handle:      options.handle };

    if(options.starteffect)
      options_for_draggable.starteffect = options.starteffect;

    if(options.reverteffect)
      options_for_draggable.reverteffect = options.reverteffect;
    else
      if(options.ghosting) options_for_draggable.reverteffect = function(element) {
        element.style.top  = 0;
        element.style.left = 0;
      };

    if(options.endeffect)
      options_for_draggable.endeffect = options.endeffect;

    if(options.zindex)
      options_for_draggable.zindex = options.zindex;

    // build options for the droppables
    var options_for_droppable = {
      overlap:     options.overlap,
      containment: options.containment,
      tree:        options.tree,
      hoverclass:  options.hoverclass,
      onHover:     pie.sortable.onHover
    };

    var options_for_tree = {
      onHover:      pie.sortable.onEmptyHover,
      overlap:      options.overlap,
      containment:  options.containment,
      hoverclass:   options.hoverclass
    };

    // fix for gecko engine
    Element.cleanWhitespace(element);

    options.draggables = [];
    options.droppables = [];

    // drop on empty handling
    if(options.dropOnEmpty || options.tree) {
      Droppables.add(element, options_for_tree);
      options.droppables.push(element);
    }

    (options.elements || this.findElements(element, options) || []).each( function(e,i) {
      var handle = options.handles ? $(options.handles[i]) :
        (options.handle ? $(e).select('.' + options.handle)[0] : e);
      options.draggables.push(
        new Draggable(e, Object.extend(options_for_draggable, { handle: handle })));
      //11月27日 添加鼠标样式
      $(handle).setStyle({'cursor':'move'});
      Droppables.add(e, options_for_droppable);
      if(options.tree) e.treeNode = element;
      options.droppables.push(e);
    });

    if(options.tree) {
      (pie.sortable.findTreeElements(element, options) || []).each( function(e) {
        Droppables.add(e, options_for_tree);
        e.treeNode = element;
        options.droppables.push(e);
      });
    }

    // keep reference
    this.sortables[element.id] = options;

    // for onupdate
    Draggables.addObserver(new pie.sortable_observer(element, options.onUpdate));

  },

  // return all suitable-for-sortable elements in a guaranteed order
  findElements: function(element, options) {
    return Element.findChildren(
      element, options.only, options.tree ? true : false, options.tag);
  },

  findTreeElements: function(element, options) {
    return Element.findChildren(
      element, options.only, options.tree ? true : false, options.treeTag);
  },

  onHover: function(element, dropon, overlap) {
    if(Element.isParent(dropon, element)) return;

    if(overlap > .33 && overlap < .66 && pie.sortable.options(dropon).tree) {
      return;
    } else if(overlap>0.5) {
      pie.sortable.mark(dropon, 'before');
      if(dropon.previousSibling != element) {
        var oldParentNode = element.parentNode;
        element.style.visibility = "hidden"; // fix gecko rendering
        //dropon.parentNode.insertBefore(element, dropon);
        //pie.sortable.prepare_placeholder(element);
        //dropon.parentNode.insertBefore(pie.sortable._placeholder, dropon);
        pie.sortable.do_hover_insert(element,dropon.parentNode,dropon);

        if(dropon.parentNode!=oldParentNode)
          pie.sortable.options(oldParentNode).onChange(element);
        pie.sortable.options(dropon.parentNode).onChange(element);
      }
    } else {
      pie.sortable.mark(dropon, 'after');
      var nextElement = dropon.nextSibling || null;
      if(nextElement != element) {
        var oldParentNode = element.parentNode;
        element.style.visibility = "hidden"; // fix gecko rendering
        //dropon.parentNode.insertBefore(element, nextElement);
        //pie.sortable.prepare_placeholder(element);
        //dropon.parentNode.insertBefore(pie.sortable._placeholder, nextElement);
        pie.sortable.do_hover_insert(element,dropon.parentNode,nextElement);

        if(dropon.parentNode!=oldParentNode)
          pie.sortable.options(oldParentNode).onChange(element);
        pie.sortable.options(dropon.parentNode).onChange(element);
      }
    }
  },

  onEmptyHover: function(element, dropon, overlap) {
    var oldParentNode = element.parentNode;
    var droponOptions = pie.sortable.options(dropon);
    
    if(!Element.isParent(dropon, element)) {
      var index;

      var children = pie.sortable.findElements(dropon, {tag: droponOptions.tag, only: droponOptions.only});
      var child = null;

      if(children) {
        var offset = Element.offsetSize(dropon, droponOptions.overlap) * (1.0 - overlap);

        for (index = 0; index < children.length; index += 1) {
          if (offset - Element.offsetSize (children[index], droponOptions.overlap) >= 0) {
            offset -= Element.offsetSize (children[index], droponOptions.overlap);
          } else if (offset - (Element.offsetSize (children[index], droponOptions.overlap) / 2) >= 0) {
            child = index + 1 < children.length ? children[index + 1] : null;
            break;
          } else {
            child = children[index];
            break;
          }
        }
      }

      //dropon.insertBefore(element, child);
      //pie.sortable.prepare_placeholder(element);
      //dropon.insertBefore(pie.sortable._placeholder, child);
      pie.sortable.do_hover_insert(element,dropon,child);

      pie.sortable.options(oldParentNode).onChange(element);
      droponOptions.onChange(element);
    }
  },

  prepare_placeholder:function(element){
    if(!pie.sortable._placeholder){
      pie.sortable._placeholder = $(Builder.node('div',{'class':'content-placeholder content-cell'},''));
    }
    if(!pie.sortable.is_dragging){
      pie.sortable._placeholder.setStyle({'width':($(element).getWidth()-4)+'px','height':($(element).getHeight()-4)+'px'}).show();
      element.absolutize();
      pie.sortable.dragging = element;
      pie.sortable.is_dragging = true;
    }
  },

  do_hover_insert: function(element,parent,target){
    //parent.insertBefore(element, target);
    pie.sortable.prepare_placeholder(element);
    parent.insertBefore(pie.sortable._placeholder, target);
  },

  unmark: function() {
    if(pie.sortable._marker) pie.sortable._marker.hide();
  },

  mark: function(dropon, position) {
    // mark on ghosting only
    var sortable = pie.sortable.options(dropon.parentNode);
    if(sortable && !sortable.ghosting) return;

    if(!pie.sortable._marker) {
      pie.sortable._marker =
        ($('dropmarker') || Element.extend(document.createElement('DIV'))).
          hide().addClassName('dropmarker').setStyle({position:'absolute'});
      document.getElementsByTagName("body").item(0).appendChild(pie.sortable._marker);
    }
    var offsets = Position.cumulativeOffset(dropon);
    pie.sortable._marker.setStyle({left: offsets[0]+'px', top: offsets[1] + 'px'});

    if(position=='after')
      if(sortable.overlap == 'horizontal')
        pie.sortable._marker.setStyle({left: (offsets[0]+dropon.clientWidth) + 'px'});
      else
        pie.sortable._marker.setStyle({top: (offsets[1]+dropon.clientHeight) + 'px'});

    pie.sortable._marker.show();
  },

  _tree: function(element, options, parent) {
    var children = pie.sortable.findElements(element, options) || [];

    for (var i = 0; i < children.length; ++i) {
      var match = children[i].id.match(options.format);

      if (!match) continue;

      var child = {
        id: encodeURIComponent(match ? match[1] : null),
        element: element,
        parent: parent,
        children: [],
        position: parent.children.length,
        container: $(children[i]).down(options.treeTag)
      };

      /* Get the element containing the children and recurse over it */
      if (child.container)
        this._tree(child.container, options, child);

      parent.children.push (child);
    }

    return parent;
  },

  tree: function(element) {
    element = $(element);
    var sortableOptions = this.options(element);
    var options = Object.extend({
      tag: sortableOptions.tag,
      treeTag: sortableOptions.treeTag,
      only: sortableOptions.only,
      name: element.id,
      format: sortableOptions.format
    }, arguments[1] || { });

    var root = {
      id: null,
      parent: null,
      children: [],
      container: element,
      position: 0
    };

    return pie.sortable._tree(element, options, root);
  },

  /* Construct a [i] index for a particular node */
  _constructIndex: function(node) {
    var index = '';
    do {
      if (node.id) index = '[' + node.position + ']' + index;
    } while ((node = node.parent) != null);
    return index;
  },

  sequence: function(element) {
    element = $(element);
    var options = Object.extend(this.options(element), arguments[1] || { });

    return $(this.findElements(element, options) || []).map( function(item) {
      return item.id.match(options.format) ? item.id.match(options.format)[1] : '';
    });
  },

  setSequence: function(element, new_sequence) {
    element = $(element);
    var options = Object.extend(this.options(element), arguments[2] || { });

    var nodeMap = { };
    this.findElements(element, options).each( function(n) {
        if (n.id.match(options.format))
            nodeMap[n.id.match(options.format)[1]] = [n, n.parentNode];
        n.parentNode.removeChild(n);
    });

    new_sequence.each(function(ident) {
      var n = nodeMap[ident];
      if (n) {
        n[1].appendChild(n[0]);
        delete nodeMap[ident];
      }
    });
  },

  serialize: function(element) {
    element = $(element);
    var options = Object.extend(pie.sortable.options(element), arguments[1] || { });
    var name = encodeURIComponent(
      (arguments[1] && arguments[1].name) ? arguments[1].name : element.id);

    if (options.tree) {
      return pie.sortable.tree(element, arguments[1]).children.map( function (item) {
        return [name + pie.sortable._constructIndex(item) + "[id]=" +
                encodeURIComponent(item.id)].concat(item.children.map(arguments.callee));
      }).flatten().join('&');
    } else {
      return pie.sortable.sequence(element, arguments[1]).map( function(item) {
        return name + "[]=" + encodeURIComponent(item);
      }).join('&');
    }
  }
};