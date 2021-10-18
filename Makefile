EXE = bob
MY_MAIN = bob.cpp
IMGUI_DIR = ./imgui/
CXXFLAGS = -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
CXXFLAGS += -g -Wall -Wformat
CXXFLAGS += `pkg-config --cflags glfw3`
LIBS += -lglfw3 -lgdi32 -lopengl32 -limm32

SOURCES = $(MY_MAIN)
SOURCES += $(IMGUI_DIR)/imgui.cpp $(IMGUI_DIR)/imgui_demo.cpp $(IMGUI_DIR)/imgui_draw.cpp $(IMGUI_DIR)/imgui_tables.cpp $(IMGUI_DIR)/imgui_widgets.cpp
SOURCES += $(IMGUI_DIR)/backends/imgui_impl_glfw.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp
OBJS = $(addsuffix .o, $(basename $(notdir $(SOURCES))))

%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o:$(IMGUI_DIR)/backends/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

all: $(EXE)
	@echo Build complete for MinGW

$(EXE): $(OBJS)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LIBS)

clean:
	rm -f $(EXE) $(OBJS)




.PHONY:
what-compiler:
	@echo $(CXX)

libs.txt: $(MY_MAIN)
	$(CXX) $(CXXFLAGS) $< -M > $@

.PHONY: tags
tags: $(MY_MAIN)
	ctags --c-kinds=+l --exclude=Makefile -R .

.PHONY: lib-tags
lib-tags: libs.txt
	python.exe parse-lib-tags.py
	rm -f headers-windows.txt
	ctags -f lib-tags --c-kinds=+p -L headers-posix.txt
	rm -f headers-posix.txt
