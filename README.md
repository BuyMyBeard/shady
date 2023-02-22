An attempt at making it easier to play around with custom GLSL shaders in Flutter. Consider WIP and unstable until minor is bumped.

## Getting started

Use Flutter 3.7 or later, and follow [this guide](https://docs.flutter.dev/development/ui/advanced/shaders).

## How to use
1. In your code, prepare a `Shady` instance with details about the shader programs you want to use. It's important to add *all* uniforms and textures, and to add them in *the same order* as they appear in the shader program.

    ```
    /* myShader.frag */

    uniform float uniformOne;
    uniform float uniformTwo;
    uniform sampler2D textureOne;

    [...]
    ```

    ```
    /* Flutter code */

    final shady = Shady([
      ShadyShader(
        key: 'myShader',
        asset: 'assets/shaders/myShader.frag',
        uniforms: [
          ShadyUniformFloat(key: 'uniformOne'),
          ShadyUniformFloat(key: 'uniformTwo'),
        ],
        textures: [
          ShadyTexture(
            key: 'textureOne',
            asset: 'assets/texture1.png',
          ),
        ],
      ),
    ]);

    [...]
    ```
2. When appropriate, load the shader programs.
    ```
    await shady.load();
    ```
3. Use one of the supplied widgets where you want to display your shader.
    ```
    SizedBox(
      width: 200,
      height: 200,
      child: ShadyCanvas(
        shader: shady.get('myShader'),
      ),
    ),
    ```
4. Modify your shader parameters by using your `Shady` instance whenever
    ```
    shady.get('myShader').setValue('uniformOne', 0.4);
    shady.get('myShader').setTexture('textureOne', 'assets/texture2.png');
    ```

## Other features

#### Transformers

Transformers are callbacks that are called every frame to transform a uniform value using the previous value and a delta time.

```
  ShadyUniformFloat(
    key: 'transformedFloat',
    transformer: (previousValue, deltaSeconds) => previousValue + deltaSeconds,
  )
```

There are some static premade transforms available on the `Uniform*` classes.

```
  ShadyUniformFloat(
    key: 'transformedFloat',
    transformer: ShadyUniformFloat.secondsPassed,
  )
```

Transformers can be switched.

```
  shady.get('myShader').setTransformer((prev, dt) => prev + (dt * 2));
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

Then, when defining your `ShadyShader`, flag it using the parameter `shaderToy` to automatically add and wire the listed uniforms such that it mostly works.

```
ShadyShader(
  key: 'myStShader'
  asset: 'assets/shaders/myShaderToyShader.frag'),
  shaderToy: true,
),
```

Only the ShaderToy uniforms listed are supported, and the only supported data type for channels is 2D textures (`sampler2D`).

`iMouse` might be supported at some point somehow.

## Additional information

The `example` app is a gallery of various shaders sourced from elsewhere. Have a look for inspiration and such.