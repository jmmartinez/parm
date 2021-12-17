# PARM

Bunch of scripts to create slides with Marp (https://github.com/marp-team/marp).

## CMake Integration

```cmake
find_package(Marp REQUIRED)
marp_slides(slides
            INPUT slides.md
            DEPENDS source_code.c
)
```

## Inline Python

### Generate text

```python
</python
  for i in range(0,4):
    print("This is a line {0}".format(i))
/>
```

### Inline files 

```python
</python inline_file("source_code.c") />
```

### Launch external commands 

```python
run_command("ls")
/>
```
