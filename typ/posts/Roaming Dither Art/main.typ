#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "漫游 Dither Art",
  authors: (
    (
      name: "Vkango",
      email: "hivkan@outlook.com",
    ),
  ),
)

#set par(justify: true)
#set heading(numbering: "1.")

#set text(font: ("New Computer Modern", "Source Han Serif"))
#show math.equation: set text(font: ("New Computer Modern Math", "Source Han Serif"))

#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

#set heading(numbering: "1.1.")

#let theorem = thmbox(
  "theorem",
  "Theorem",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong,
)
#let definition = thmbox(
  "definition",
  "Definition",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

_Welcome home. Consider this an odyssey of the mind._

这是一个头脑风暴文章, 目的是拓宽视野, 将多个领域知识穿插理解, 可能并不严谨.

#v(50pt)

// #title[漫游 Dither Art]

不知道你对这张图是否有记忆.

#figure(
  caption: [Windows 95 安装背景图],
  image("image.png"),
)

我个人是一个Gen-Z, 打我记事起已经是Windows XP的天下了. 之前在安装Windows 95虚拟机时, 这张图片尤为吸引我. 好吧, 可能我本身就很喜欢这种核味十足的图片了.

下面就围绕它来讲讲故事.

#v(50pt)


= 放大

如果把这张图放大化, 你会发现:

- 很多我们以为的"亮面", "阴影", "过渡", 其实并不是由连续变化的颜色值画出来的.

- 在这张图里, 它其实就可以被抽象成两种像素: 蓝色 和 黑色.

但是缩放回正常观看的距离后, 又觉得, 鼠标外壳确实是圆的, 键盘边缘确实是有层次感的, 光盘的反光也确实是画出来的.

所以两种颜色, 也能"冒充出"很多层明暗. 这和灰度图完全不同.

这张图实际上属于Dithering Art (抖动/半色调). 非常有意思. 我们在这篇文章中讨论它的简单原理.

= 数字图像

== 数字图像的数学表示

一张RGB数字图像, 可以看成一个三维张量, 即$X in RR^(H times W times 3)$.

#set math.mat(delim: "[")

对于每个像素$(i,j)$, 都有一个颜色向量$ x_(i j)=mat(r_(i j); g_(i j); b_(i j))in RR^3 $

如果颜色是8-bit的, 那么每个通道可取$0~255$.

== 采样与量化

采样, 即把连续世界景观切成一个个的像素格子.

量化, 即把连续的颜色值压到有限个离散值上.

// 采样决定"有多少格子", 而量化决定"每个格子里能填多少颜色".

如果颜色种类很多, 过渡是很容易平滑的. 如果颜色很少, 很容易出现颜色断层, 视觉上看就是一块一块的.

== 调色板限制

下面假设每个像素只能从调色板中二选一, 调色板为:$ cal(P)={p_0,p_1} $其中, $p_0=mat(0; 0; 0)$ (黑色), $p_1=mat(0; 1; 1)$ (蓝色). 同时我们把数值归一化到了$[0,1]$. 严格限制单个像素的输出只能是$q_(i j)in{p_0,p_1}$. 就是纯蓝, 没有深蓝浅蓝之类的.

= 两种颜色如何伪装出很多层次

== 平均颜色

单个像素肯定是做不出来的. 我们考虑一个区域.

设某个局部小块 $Omega$ 内一共有 $K$ 个像素. 对于第$k$个像素, 定义$ z_k =cases(0\,"选黑色", 1\,"选蓝色") $

那么该区域的平均颜色就是$ overline(c)=1/K sum_(k=1)^K (z_k p_1+(1-z_k)p_0) $


整理可得, $ overline(c)=p_0+(1/K sum_(k=1)^K z_k)(p_1-p_0) $

定义:$ alpha=1/K sum_(k=1)^K z_k $

则:$ overline(c)=p_0+alpha(p_1-p_0) $

观察此式, 虽然每个像素只能取2种颜色, 但是一个$K$像素的小区域, 平均后可以表示这么多层级:$ alpha in {0,1/K,2/K,...,1} $

因此Dithering最核心的伪装, 莫过于是"小区域平均可近似连续".

如果这块区域里, 蓝点很少, 黑点很多, 那它看起来就偏暗; 蓝点很多, 黑点很少, 那看起来就偏亮. 蓝点的密度在渐变, 因此我们就能感受到"表面亮度在平滑变化". 这张图也就是在表示局部区域里蓝色像素所占的比例.

== 亮度的解释

人的眼睛其实不能直接感受RGB三维向量本身, 而是更接近感受某种亮度组合, 可以用一个简化的亮度模型表示: $ Y(c)=w^T c $

其中, $ w=mat(0.2126; 0.7152; 0.0722) $

是常见的线性亮度权重. 于是局部平均亮度可以定义为:$ Y(overline(c))=w^T overline(c) $

代入上式:$ Y(overline(c))=w^T p_0+alpha w^T (p_1-p_0) $

如果$p_0$是黑色, 那么$w^T p_0=0$, 所以有$ Y(overline(c))=alpha w^T p_1 $

因此亮度基本上只由蓝点占比$alpha$来决定.


= 怎么造

那这种图像是怎么被画出来的呢?

== 颜色空间中的投影

设目标颜色是$c in RR^3$, 且调色板中只有$p_0,p_1$两种颜色.

那么所有能通过"区域平均"得到的颜色, 都可以落在这个线上:$ {p_0+alpha(p_1-p_0):alpha in [0,1]} $

其实就是RGB空间里的一个仿射一维子空间. 那么我们的任务可以写成, 给定一个目标颜色$c_i$, 我们去使用这个线段上的某个点去近似它.

从最小二乘的角度来看, 即:$ min_(alpha in[ 0,1])||c-(p_0+alpha(p_1-p_0))||^2_2 $

本身就是在子空间中, 因此可以正常使用向量距离. 同时, 我们也可以对$alpha$求导得最优系数$ alpha^*="clip"(((c-p_0)^T (p_1-p_0))/(||p_1-p_0||^2_2),0,1) $

$"clip"(dot)$ 将其截断到$[0,1]$之间.

所以Dithering的核心方法是, 将目标颜色投影到"可表示的颜色线段"上, 然后用空间排列去近似这个投影点.

== 从"颜色投影"到"像素排布"

求出$alpha^*$后, 如果这个区域有$K$个像素, 那么最自然的做法就是选取$ m approx K alpha^* $个像素涂成*蓝色*, 其余的全部涂成黑色. 那么下一个问题就是, 这$m$个蓝点*放在那里*.

这里不同的Dithering算法可以有不同的实现.

= Dithering的原理

== 不抖动

最简单的量化方式, 直接进行阈值来硬控. 即设置目标灰度系数为$g_(i j)in [0,1]$, 定义$ q_(i j)=cases(1\,g_(i j)>=tau, 0\,g_(i j)<tau) $

这是最简单的方法. 但是效果也很差.// 例如我的头像:
// #figure(caption: [黑白化, 阈值为25%])[
//   #grid(columns: (1fr, 1fr), gutter: 10pt)[
//     #image("avatar.jpg")][#image("avatar_simple.png")]]

```python
import numpy as np
from PIL import Image

def load_grayscale(path):
    img = Image.open(path).convert("L")
    arr = np.asarray(img, dtype=np.float32) / 255.0
    return arr

def save_binary(arr, path):
    img = Image.fromarray((arr * 255).astype(np.uint8))
    img.save(path)

def threshold_dither(img, thresh=0.5):
    return (img >= thresh).astype(np.float32)
```

== 随机抖动 (Random Dithering)

给阈值加点随机性. 定义$ Q_(i j)=cases(1\,quad I_(i j)>=U_(i j), 0\,quad I_(i j)<U_(i j)) $

其中, $U_(i j)~cal(U)(0,1)$.

```python
def random_dither(img, seed=0):
    rng = np.random.default_rng(seed)
    noise = rng.random(img.shape, dtype=np.float32)
    return (img >= noise).astype(np.float32)
```

在这里我们使用了概率来表达亮度. 亮度0.8的区域, 大概会有80%的区域变亮.


== 有序抖动 (Order Dithering) 与 Bayer矩阵

一种经典的方法是, 不要使用*同一个阈值*, 而是使用一个*阈值矩阵*作为模板.

设阈值模板$T in RR^(m times m)$, 我们将这个模板按周期性平铺到整张图上, 则量化规则变为:$ q_(i j)=cases(1\,g_(i j)>=T_(i mod m,j mod m), 0\,g_(i j)<T_(i mod m,j mod m)) $

最小的$2times 2$ Bayer模板可以写成$ T=1/4 mat(0, 2; 3, 1) $


- 比较亮的地方, 更多位置达到阈值, 蓝点会更多.

- 比较暗的地方, 较少位置达到阈值, 蓝点会更少.

所以局部蓝点密度随着$g_(i j)$变化.

有序抖动的本质就是把"灰度大小"变成"周期图案中的点密度".

== 误差扩散

也是一种经典方法. 它利用了当前像素硬量化完之后产生的误差, 并将其分配给它的邻居.

设当前像素的连续值为$tilde(g)_(i j)$, 量化后则有:$ q_(i j)="Round"(tilde(g)_(i j))in {0,1} $

定义误差:$ e_(i j)=tilde(g)_(i j)-q_(i j) $

然后, 把$e_(i j)$按权重扩散到后续像素.最经典的Floyd-Steinberg权重是:
#[
  #set math.mat(delim: none)
  $ mat(times, star, 7/16; 3/16, 5/16, 1/16) $]
表示成, 从左向右扫描时, 把当前的误差分配给右边$7/16$, 左下$3/16$, 下边$5/16$, 右下$1/16$.

肯定没左或上方向, 因为已经走过了. 让它的邻居去补.

当然, 整张图按扫描的先后顺序, 可以被拉直成向量: $ g in [0,1]^N,quad q in {0,1}^N $

设$e in RR^N$表示量化误差, $A in RR^(N times N)$表示"误差向后扩散"的线性算子.

可以写成$ tilde(g)=g+A e $

误差满足$ e=tilde(g)-q $

合并可得$ e=g+A e-q $

也就是$ (I-A)e=g-q $

这说明误差扩散本质是在做一类带反馈的量化系统. 让前面的量化决策继续影响后面.

= 人眼的成像机制

人眼不是程序, 肯定不会去逐个格地去读取, 不然Dithering不可能骗到我 :)

人的视觉系统更接近于对图像做了一次*低通平滑*. 抽象成一个卷积: $ y=H q $

其中, $q$表示*实际显示出来的二值点阵图*, $H$表示视觉系统的*模糊/点扩散*函数, $y$表示我们感知到的图像. 那么如果$ q=x+e $其中, $x$是理想连续图像, $e$是抖动带来的误差, 那么感知结果就是$ y=H(x+e)=H x+H e $

所以我们想要$H e$尽量小. 注意, 不是让$e$本身小. 换句话说, 通过人眼这个低通系统后, 误差不要过于明显.

= 傅里叶变换

// == 一维直觉

// 对于一维函数$f(x)$, 如果它变化很慢, 称其频率低, 如果变化快, 则频率高. 例如$sin x$比$sin 20x$频率低.

// == 二维图像里的频率

// 图像是二维函数$ I(x,y) $它的傅里叶基底不是


记傅里叶变换为 $hat(dot)$, 有$ hat(y)(omega)=hat(H)(omega)(hat(x)(omega)+hat(e)(omega)) $

人类的视觉系统对高频通常不敏感. 可以粗略理解为, 低频下为大块的明暗变化, 很敏感. 而高频则为细碎噪声, 相对来说不是很敏感.

如果我们把$hat(e)(omega)$都推到高频去, 那么经过$hat(H)(omega)$后, 就不那么显眼了.

Dithering的一个本质, 就是把原来会形成大块色带的低频量化误差, 改造成更细碎, 更分散的高频纹理. 这样它就骗过了我们的眼睛.

= "Shape from Shading"

人眼看到的不只是亮度, 还会自动做形状解释. 当一张图内存在平滑亮度梯度时, 人眼会自动进一步推理表面, 光源, 高光, 遮蔽等信息.

尽管微观上只有蓝点和黑点, 但是宏观上来看, 亮度场是连续的, 所以我们可以自动脑补出鼠标的弧度, 物体的体积感, 光盘的反光等.

设图像平面上某点附近的蓝点占比为$alpha(x, y)$, 则该处感知亮度可近似写成$ L(x,y)approx alpha(x, y)L_"blue" $其中, $L_"blue"$是纯蓝像素的亮度贡献. 如果$alpha(x, y)$是平滑变化的, 那么$L(x,y)$也是平滑变化的. 于是亮度梯度$ nabla L(x,y) $就成为人眼感知曲面和光照的重要线索. 因此, 图里的"亮面"和"阴影", 直接以蓝点密度的平滑变化的形式存在即可.

= 优化问题

把图像拉成一个向量, 设目标连续图像为$ x in [0,1]^N $想要生成一个二值图像$ q in {0,1}^N $设$H in RR^(N times N)$表示视觉低通算子, 那么一个很理想化的Dithering目标可以写成$ min_(q in {0,1}^N)||H q-H x||^2_2 $

我们追求的就是经过观察系统后仍然大致上一致.

考虑RGB三通道, 可以写成$ min_(q in {0,1}^N)||(H times.circle I_3)c(q)-(H times.circle I_3)x||_2^2 $

其中, $times.circle$表示Kronecker积, $I_3$是三维单位矩阵, $c(q)$表示由二值选择$q$生成的实际颜色向量.

但是这个问题还是离散的, 高维的. 直接求全局最优并不现实.

于是就有了各种的近似算法, 在前面进行了介绍.

= Computer Vision

== 量化感知训练

深度学习经常把模型或激活量化到*低比特*. 例如$hat(x)=Q(x)$, 其中$Q$是round / clip / sign之类的离散化操作. 本质上就是把连续空间映射到离散空间.

量化误差也不一定会形成结构性失真, Dithering思想指出, 误差并不一定要变小, 但是可以让误差变得"更不相关", "更不成块", "更像噪声".

例如, 训练时加入均匀噪声$ u~cal(U)(-Delta/2,Delta/2) $

然后用$ x+u $
去近似量化误差的影响. 把结构化误差打散成更容易处理的噪声.

== 可微分半色调 / 神经抖动

也有人直接让网络学Dithering. 设网络输出一个接近二值的图: $ q_theta=G_theta (x) $
然后要求它在经过某种算子$H$后, 与原图一致, 即$ min_theta ||H q_theta-x||_1 $

或者使用感知损失$ min_theta||Phi(H q_theta)-Phi(x)||_2^2 $

此处$Phi$可以用卷积网络等特征提取器. 当然, 抖动图也可以被网络学习, 试着恢复成连续图像. 这对于老照片恢复是很有用的.

== 频域鲁棒性

CNN其实很容易把高频纹理*误当作*"有用特征", 而Dithering恰好会制造很强的高频模式. 如果训练集总是现代高清图像, 测试时突然来一张老式抖动图, 模型就可能会过度关注*点状纹理*, 而忽略了*低频的形状*.

== Swin Transformer

Swin Transformer核心是做Window-based Self-Attention, 然后再做*Shifted Window*. 在这里, 如果直接shift, 就会打乱原本窗口分块, 所以实现时常用cyclic shift + attention mask.

这个mask的作用是:

- 某些token虽然在循环位移后被放进同一个window tensor里.

- 但是它们并不属于同一局部邻域.

- 要用mask把它们的注意力打掉.

即$ M_(i j)=cases(0\,quad&i\,j "允许互相注意", -oo\,quad&i\,j "不允许") $

再加到Attention Logits上:$ A="softmax"((Q K^T)/sqrt(d)+M) $

Mask是一种*结构约束*.

其实Swin Transformer倒是和Dithering在方法论上没有直接关系. 我写这个是因为, 当时Swin Transformer的mask可视化后很像Dithering而已.

// 硬要说关系, 其实这两个更像是*局部性*和*重复性*的应用典范. 例如, Shifted Window是让第一次注意力只在固定窗口内, 而第二次通过Shift, 让边界附近的信息跨窗交流. Ordered Dithering里的阈值模板

硬要说关系, 可以从哲学的角度进行. 感觉很多东西都可以抽象成:

- 先用某个*局部*Pattern来进行*约束*计算.

- 再通过Shift / Phase Offset / Mask 来让整体不要太死板.

比如说Ordered Dithering, 我们可以认为它是固定阈值模板的周期排布, 而Swin Transformer是固定Window划分, 用Shifted Window让其与周围建立联系. 卷积则是通过Receptive Field + 堆叠层来扩大感受野.

如果把Dithering视为一种"离散纹理生成机制", 那么也许可以设计一个小模块, 让网络学习如何*分配局部点密度*, 以及*如何通过Shift来打破格子的伪影*, 同时*最小化感知误差*. 也是一些比较有趣的问题.

// #pagebreak()
#v(50pt)
#figure(caption: [此图由GPT-Image 2生成], image("image1.png", width: 60%))
