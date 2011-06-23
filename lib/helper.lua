-- python-like modulo operator on strings
getmetatable("").__mod = function(s, a)
	if not a then
		return s
	elseif type(a) == "table" then
		return s:format(unpack(a))
	else
		return s:format(a)
	end
end

-- convert bool to number
bool = { [true] = 1, [false] = 0 }

-- we need some nice oo
Object = {}
function Object:new(o)
	o = o or {}
	setmetatable(o, self)
	local m = getmetatable(self)
	self.__index = self
	self.__call = m.__call
	self.super = m.__index and m.__index.init
	return o
end
setmetatable(Object, { __call = function(self, ...)
	local o = self:new()
	if o.init then o:init(...) end
	return o
end })


-- test oo stuff
if test then

	Vec2d = Object:new { x = 4, y = 0 }
	function Vec2d:__tostring()
		return "Vec2d{x = %g, y = %g}" % { self.x, self.y }
	end

	Vec3d = Vec2d:new { z = 0 }
	function Vec3d:__tostring()
		return "Vec3d{x = %g, y = %g, z = %g}" % { self.x, self.y, self.z }
	end

	a = Vec2d()
	b = Vec3d()
	print(a)
	print(b)
	print()

	-- test with :init and :super
	Box = Object()
	function Box:init(text)
		self.text = text
	end
	function Box:put()
		print("< %s >" % self.text)
	end

	SuperBox = Box:new()
	function SuperBox:init(text, frame)
		self.super:init(text)
		self.frame = frame or "#"
	end

	function SuperBox:put()
		print(self.frame:rep(#self.text + 4))
		print("%s %s %s" % { self.frame, self.text, self.frame })
		print(self.frame:rep(#self.text + 4))
	end

	w = Box("hallo")
	w:put()

	c = SuperBox("hi there", "/")
	c:put()

end

