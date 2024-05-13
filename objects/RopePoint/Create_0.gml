event_inherited()

radius = 2
height = 2

f_bump_avoid = true

pinned = false

#region Virtual Functions
bump_check = function (_self, _from) {
	return not _from.is_ancestor(RopePoint)
}
#endregion