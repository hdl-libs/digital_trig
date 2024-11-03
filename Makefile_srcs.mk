
VVP_INCLUDEDIR=
VVP_INCLUDEDIR+=-I ./src/
VVP_INCLUDEDIR+=-I ./sim/

VVP_CFLAGS=
VVP_CFLAGS+=-g2005-sv

VVP_SRCS=
VVP_SRCS+= ./src/trig_wrapper.v
VVP_SRCS+= ./src/trig_apb_ui.v
VVP_SRCS+= ./src/trig_cmp.v
VVP_SRCS+= ./src/trig8.v

# VVP_SRCS+= ./sim/trig_wrapper.v
# VVP_SRCS+= ./sim/trig_apb_ui.v
# VVP_SRCS+= ./sim/trig_cmp_tb.v
VVP_SRCS+= ./sim/trig8_tb.v