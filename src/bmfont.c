#include "mruby.h"
#include "mruby/class.h"

#include <allegro5/allegro.h>

static mrb_value
bmfont_each_codepoint_from(mrb_state *mrb, mrb_value self)
{
  char *cstr;
  mrb_value blk;

  ALLEGRO_USTR *ustr;
  int pos = 0;
  int codepoint = 0;

  mrb_get_args(mrb, "z&", &cstr, &blk);

  ustr = al_ustr_new(cstr);

  for (codepoint = al_ustr_get_next(ustr, &pos); codepoint > 0; codepoint = al_ustr_get_next(ustr, &pos)) {
    mrb_yield(mrb, blk, mrb_fixnum_value(codepoint));
  }

  if (ustr) al_ustr_free(ustr);

  return mrb_nil_value();
}

void
mrb_mruby_minigame_bmfont_gem_init(mrb_state *mrb)
{
  struct RClass *c;
  
  c = mrb_define_class_under(mrb, mrb_module_get(mrb, "Minigame"), "BMFont", mrb->object_class);
  MRB_SET_INSTANCE_TT(c, MRB_TT_DATA);

  mrb_define_method(mrb, c, "each_codepoint_from", bmfont_each_codepoint_from, MRB_ARGS_REQ(2));
}

void
mrb_mruby_minigame_bmfont_gem_final(mrb_state *mrb)
{
}
