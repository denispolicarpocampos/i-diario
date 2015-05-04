module Navigation
  class MenuBuilder < Base
    def initialize(item, user, render = MenuRender)
      super(item, user, render)
    end

    def build
      amount_***REMOVED***s
      render
    end

    protected

    def amount_***REMOVED***s
      amount_nodes navigation do |***REMOVED***|
        ***REMOVED***s << ***REMOVED***
      end
    end

    def amount_nodes(nodes, parent_***REMOVED*** = nil)
      nodes ||= []

      nodes.select do |node|
        visible = node["***REMOVED***"]["visible"]
        next if (!visible.nil? && visible == false) || (visible == 'only-when-active' && node["***REMOVED***"]["type"] != item)
        yield node_values(node["***REMOVED***"], parent_***REMOVED***)
      end
    end

    def node_values(node, parent_***REMOVED***)
      {}.tap do |***REMOVED***|
        ***REMOVED***[:type]      = node["type"]
        ***REMOVED***[:icon]      = node["icon"]
        ***REMOVED***[:path]      = node["path"]
        ***REMOVED***[:visible]   = node["visible"]
        ***REMOVED***[:css_class] = []
        ***REMOVED***[:subnodes]  = []

        if ***REMOVED***[:type] == item
          ***REMOVED***[:css_class] << :current
          parent_***REMOVED***[:css_class] << :open if parent_***REMOVED***
        end

        node["sub***REMOVED***s"] ||= []
        amount_nodes node["sub***REMOVED***s"], ***REMOVED*** do |subnode|
          ***REMOVED***[:subnodes] << subnode
        end
        true
      end
    end

    def render
      navigation_render.render(***REMOVED***s)
    end
  end
end
