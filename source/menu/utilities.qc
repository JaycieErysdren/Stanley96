//
// utilities.qc
//

// useful functions for operating the menusys go here

struct binds_t {
	string name;
	string command;
};

binds_t bindlist[] = 
{
	{ _("m_key_moveforward"), "+forward" },
	{ _("m_key_moveback"), "+back" },
	{ _("m_key_moveleft"), "+moveleft" },
	{ _("m_key_moveright"), "+moveright" },
	{ _("m_key_use"), "+button3" },
	{ _("m_key_crouch"), "+button4" },
	{ _("m_key_kick"), "+button5" },
	{ _("m_key_attack"), "+attack" },
	{ _("m_key_reload"), "+button6" },
	{ _("m_key_equip01"), "impulse 1" },
	{ _("m_key_equip02"), "impulse 2" },
	{ _("m_key_equip03"), "impulse 3" }
};