An attempt at making it easier to play around with custom GLSL shaders in Flutter. Consider WIP and unstable until minor is bumped.

## Getting started

Use Flutter 3.7 or later, and follow [this guide](https://docs.flutter.dev/development/ui/advanced/shaders).

## How to use
1. In your code, prepare a `Shady` instance with details about the shaders you want to use. It's important to add *all* uniforms, and to add them in *the same order* that they appear in the shader code.
    ```
    final shady = Shady([
      ShaderDetails('assets/myshader.frag')
        ..usesUniform(UniformFloat('friendlyNameOne'))
        ..usesUniform(UniformFloat('friendlyNameTwo')),
    ]);
    ```
2. When appropriate, load the shader programs.
    ```
    await shady.load();
    ```
3. Use the `ShadyCanvas` widget where you want to use your shader.
    ```
    SizedBox(
      width: 200,
      height: 200,
      child: ShadyCanvas(
        shader: shady.get('assets/myshader.frag'),
      ),
    ),
    ```
4. Modify the uniforms of your shaders whenever by using your `Shady` instance
    ```
    final shader = shady.get('assets/myshader.frag');
    shader.setUniform('friendlyNameOne', 0.4);
    ```

## Other features

#### Textures

Texture samplers are defined the same way as uniforms. However, you need to provide a Flutter `BuildContext` for Shady to be able to resolve image files.

```
  ShaderDetails('assets/myshader.frag')
    ..usesTexture(
      Texture(context, 'friendlyName', 'assets/image.png'),
    )
```

Textures can be switched like uniforms:

```
final shader = shady.get('assets/myshader.frag');
shader.setTexture('friendlyName', 'assets/image2.png');
```


#### Transformers

You can set a transformer to be used by a uniform value. This is a callback that is called every frame for you to transform the value however you want.

```
  ShaderDetails('assets/myshader.frag')
    ..usesUniform(
      'friendlyName',
      UniformFloat(0)
        ..withTransformer(
          (previousValue, deltaSeconds) => previousValue + deltaSeconds,
        )),
```

There are some static premade transforms available on the `Uniform*` classes.

```
  ShaderDetails('assets/myshader.frag')
    ..usesUniform(
      UniformFloat('friendlyName', 0)
        ..withTransformer(
          UniformFloat.withTransformer(UniformFloat.secondsPassed)
        )
    ),
```

#### Using ShaderToy shaders

[ShaderToy](https://www.shadertoy.com/) is an awesome playground for GLSL experimentation. However, both it and Flutter have some quirks and magic in how shaders are written.

To use a ShaderToy shader (with some limitations), wrap it like this:
```
#include <flutter/runtime_effect.glsl>
uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform vec4 iMouse;
out vec4 fragColor;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
////////////// Shadertoy BEGIN

[ Paste your Shadertoy code here ]

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
```

Then, when adding your `ShaderDetails`, call the magic `.usesShaderToyUniforms()` method to automatically add and wire the listed uniforms such that it mostly works.

```
ShaderDetails('assets/shaders/myshader.frag')
  ..usesShaderToyUniforms(context);
```

Only the ShaderToy uniforms listed are supported, and the only supported data type for channels is 2D textures (`sampler2D`).

`iMouse` might be supported at some point somehow.

## Additional information

The `example` app is a gallery of various shaders sourced from elsewhere. Have a look for inspiration and such.