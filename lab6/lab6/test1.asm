
_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, char *argv[]) {
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 54             	sub    $0x54,%esp
  15:	89 c8                	mov    %ecx,%eax

    int NCHILD;

    if(argc<2)
  17:	83 38 01             	cmpl   $0x1,(%eax)
  1a:	7f 09                	jg     25 <main+0x25>
        NCHILD = 2;
  1c:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  23:	eb 17                	jmp    3c <main+0x3c>
    else 
        NCHILD = atoi(argv[1]);
  25:	8b 40 04             	mov    0x4(%eax),%eax
  28:	83 c0 04             	add    $0x4,%eax
  2b:	8b 00                	mov    (%eax),%eax
  2d:	83 ec 0c             	sub    $0xc,%esp
  30:	50                   	push   %eax
  31:	e8 81 03 00 00       	call   3b7 <atoi>
  36:	83 c4 10             	add    $0x10,%esp
  39:	89 45 f4             	mov    %eax,-0xc(%ebp)

    printf(1, "*Case1: Parent has no children*\n");
  3c:	83 ec 08             	sub    $0x8,%esp
  3f:	68 a0 09 00 00       	push   $0x9a0
  44:	6a 01                	push   $0x1
  46:	e8 8a 05 00 00       	call   5d5 <printf>
  4b:	83 c4 10             	add    $0x10,%esp
    int wtime1, rtime1;
    int status = wait2(&wtime1, &rtime1);
  4e:	83 ec 08             	sub    $0x8,%esp
  51:	8d 45 dc             	lea    -0x24(%ebp),%eax
  54:	50                   	push   %eax
  55:	8d 45 e0             	lea    -0x20(%ebp),%eax
  58:	50                   	push   %eax
  59:	e8 93 04 00 00       	call   4f1 <wait2>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(status == -1) {
  64:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
  68:	75 17                	jne    81 <main+0x81>
        printf(1, "wait2 status: %d\n", status);
  6a:	83 ec 04             	sub    $0x4,%esp
  6d:	ff 75 e8             	pushl  -0x18(%ebp)
  70:	68 c1 09 00 00       	push   $0x9c1
  75:	6a 01                	push   $0x1
  77:	e8 59 05 00 00       	call   5d5 <printf>
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	eb 12                	jmp    93 <main+0x93>
    } else {
        printf(1, "wait2 should return -1 if calling process has no children\n");
  81:	83 ec 08             	sub    $0x8,%esp
  84:	68 d4 09 00 00       	push   $0x9d4
  89:	6a 01                	push   $0x1
  8b:	e8 45 05 00 00       	call   5d5 <printf>
  90:	83 c4 10             	add    $0x10,%esp
    }


    printf(1, "*Case2: Parent has children*\n");
  93:	83 ec 08             	sub    $0x8,%esp
  96:	68 0f 0a 00 00       	push   $0xa0f
  9b:	6a 01                	push   $0x1
  9d:	e8 33 05 00 00       	call   5d5 <printf>
  a2:	83 c4 10             	add    $0x10,%esp
    for ( int child = 0; child < NCHILD; child++ ) {
  a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  ac:	e9 c6 00 00 00       	jmp    177 <main+0x177>
        int pid = fork ();
  b1:	e8 93 03 00 00       	call   449 <fork>
  b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if ( pid < 0 ) {
  b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  bd:	79 1d                	jns    dc <main+0xdc>
            printf(1, "%d failed in fork!\n", getpid());
  bf:	e8 0d 04 00 00       	call   4d1 <getpid>
  c4:	83 ec 04             	sub    $0x4,%esp
  c7:	50                   	push   %eax
  c8:	68 2d 0a 00 00       	push   $0xa2d
  cd:	6a 01                	push   $0x1
  cf:	e8 01 05 00 00       	call   5d5 <printf>
  d4:	83 c4 10             	add    $0x10,%esp
            exit();
  d7:	e8 75 03 00 00       	call   451 <exit>
        } else if (pid == 0) {
  dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  e0:	0f 85 8d 00 00 00    	jne    173 <main+0x173>
            sleep(100);
  e6:	83 ec 0c             	sub    $0xc,%esp
  e9:	6a 64                	push   $0x64
  eb:	e8 f1 03 00 00       	call   4e1 <sleep>
  f0:	83 c4 10             	add    $0x10,%esp
            printf(1, "Child %d created\n",getpid());
  f3:	e8 d9 03 00 00       	call   4d1 <getpid>
  f8:	83 ec 04             	sub    $0x4,%esp
  fb:	50                   	push   %eax
  fc:	68 41 0a 00 00       	push   $0xa41
 101:	6a 01                	push   $0x1
 103:	e8 cd 04 00 00       	call   5d5 <printf>
 108:	83 c4 10             	add    $0x10,%esp
            volatile double a, b;
            a = 3.14;
 10b:	dd 05 c0 0a 00 00    	fldl   0xac0
 111:	dd 5d c8             	fstpl  -0x38(%ebp)
            b = 36.29;
 114:	dd 05 c8 0a 00 00    	fldl   0xac8
 11a:	dd 5d c0             	fstpl  -0x40(%ebp)
            volatile double x = 0, z;
 11d:	d9 ee                	fldz   
 11f:	dd 5d b8             	fstpl  -0x48(%ebp)
            for (z = 0; z < 90000.0; z += 0.1)
 122:	d9 ee                	fldz   
 124:	dd 5d b0             	fstpl  -0x50(%ebp)
 127:	eb 1e                	jmp    147 <main+0x147>
            {
                x = x + a * b; 
 129:	dd 45 c8             	fldl   -0x38(%ebp)
 12c:	dd 45 c0             	fldl   -0x40(%ebp)
 12f:	de c9                	fmulp  %st,%st(1)
 131:	dd 45 b8             	fldl   -0x48(%ebp)
 134:	de c1                	faddp  %st,%st(1)
 136:	dd 5d b8             	fstpl  -0x48(%ebp)
            for (z = 0; z < 90000.0; z += 0.1)
 139:	dd 45 b0             	fldl   -0x50(%ebp)
 13c:	dd 05 d0 0a 00 00    	fldl   0xad0
 142:	de c1                	faddp  %st,%st(1)
 144:	dd 5d b0             	fstpl  -0x50(%ebp)
 147:	dd 45 b0             	fldl   -0x50(%ebp)
 14a:	dd 05 d8 0a 00 00    	fldl   0xad8
 150:	df f1                	fcomip %st(1),%st
 152:	dd d8                	fstp   %st(0)
 154:	77 d3                	ja     129 <main+0x129>
            }
            printf(1, "Child %d finished\n",getpid());
 156:	e8 76 03 00 00       	call   4d1 <getpid>
 15b:	83 ec 04             	sub    $0x4,%esp
 15e:	50                   	push   %eax
 15f:	68 53 0a 00 00       	push   $0xa53
 164:	6a 01                	push   $0x1
 166:	e8 6a 04 00 00       	call   5d5 <printf>
 16b:	83 c4 10             	add    $0x10,%esp
            exit();
 16e:	e8 de 02 00 00       	call   451 <exit>
    for ( int child = 0; child < NCHILD; child++ ) {
 173:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 177:	8b 45 f0             	mov    -0x10(%ebp),%eax
 17a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 17d:	0f 8c 2e ff ff ff    	jl     b1 <main+0xb1>
        }
    }
    int wtime, rtime;
    for(int i=0; i<NCHILD; i++){
 183:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 18a:	eb 3d                	jmp    1c9 <main+0x1c9>
        status = wait2(&wtime, &rtime);
 18c:	83 ec 08             	sub    $0x8,%esp
 18f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 192:	50                   	push   %eax
 193:	8d 45 d8             	lea    -0x28(%ebp),%eax
 196:	50                   	push   %eax
 197:	e8 55 03 00 00       	call   4f1 <wait2>
 19c:	83 c4 10             	add    $0x10,%esp
 19f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        printf(1, "Child no. %d, Child pid: %d exited with Status: %d, Waiting Time: %d, Run Time: %d\n", i, status, status, wtime, rtime);
 1a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 1a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
 1a8:	83 ec 04             	sub    $0x4,%esp
 1ab:	52                   	push   %edx
 1ac:	50                   	push   %eax
 1ad:	ff 75 e8             	pushl  -0x18(%ebp)
 1b0:	ff 75 e8             	pushl  -0x18(%ebp)
 1b3:	ff 75 ec             	pushl  -0x14(%ebp)
 1b6:	68 68 0a 00 00       	push   $0xa68
 1bb:	6a 01                	push   $0x1
 1bd:	e8 13 04 00 00       	call   5d5 <printf>
 1c2:	83 c4 20             	add    $0x20,%esp
    for(int i=0; i<NCHILD; i++){
 1c5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 1c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 1cf:	7c bb                	jl     18c <main+0x18c>
    }
    exit();
 1d1:	e8 7b 02 00 00       	call   451 <exit>

000001d6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	57                   	push   %edi
 1da:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1db:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1de:	8b 55 10             	mov    0x10(%ebp),%edx
 1e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e4:	89 cb                	mov    %ecx,%ebx
 1e6:	89 df                	mov    %ebx,%edi
 1e8:	89 d1                	mov    %edx,%ecx
 1ea:	fc                   	cld    
 1eb:	f3 aa                	rep stos %al,%es:(%edi)
 1ed:	89 ca                	mov    %ecx,%edx
 1ef:	89 fb                	mov    %edi,%ebx
 1f1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f7:	90                   	nop
 1f8:	5b                   	pop    %ebx
 1f9:	5f                   	pop    %edi
 1fa:	5d                   	pop    %ebp
 1fb:	c3                   	ret    

000001fc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1fc:	f3 0f 1e fb          	endbr32 
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 20c:	90                   	nop
 20d:	8b 55 0c             	mov    0xc(%ebp),%edx
 210:	8d 42 01             	lea    0x1(%edx),%eax
 213:	89 45 0c             	mov    %eax,0xc(%ebp)
 216:	8b 45 08             	mov    0x8(%ebp),%eax
 219:	8d 48 01             	lea    0x1(%eax),%ecx
 21c:	89 4d 08             	mov    %ecx,0x8(%ebp)
 21f:	0f b6 12             	movzbl (%edx),%edx
 222:	88 10                	mov    %dl,(%eax)
 224:	0f b6 00             	movzbl (%eax),%eax
 227:	84 c0                	test   %al,%al
 229:	75 e2                	jne    20d <strcpy+0x11>
    ;
  return os;
 22b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22e:	c9                   	leave  
 22f:	c3                   	ret    

00000230 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 230:	f3 0f 1e fb          	endbr32 
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 237:	eb 08                	jmp    241 <strcmp+0x11>
    p++, q++;
 239:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	0f b6 00             	movzbl (%eax),%eax
 247:	84 c0                	test   %al,%al
 249:	74 10                	je     25b <strcmp+0x2b>
 24b:	8b 45 08             	mov    0x8(%ebp),%eax
 24e:	0f b6 10             	movzbl (%eax),%edx
 251:	8b 45 0c             	mov    0xc(%ebp),%eax
 254:	0f b6 00             	movzbl (%eax),%eax
 257:	38 c2                	cmp    %al,%dl
 259:	74 de                	je     239 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
 25e:	0f b6 00             	movzbl (%eax),%eax
 261:	0f b6 d0             	movzbl %al,%edx
 264:	8b 45 0c             	mov    0xc(%ebp),%eax
 267:	0f b6 00             	movzbl (%eax),%eax
 26a:	0f b6 c0             	movzbl %al,%eax
 26d:	29 c2                	sub    %eax,%edx
 26f:	89 d0                	mov    %edx,%eax
}
 271:	5d                   	pop    %ebp
 272:	c3                   	ret    

00000273 <strlen>:

uint
strlen(const char *s)
{
 273:	f3 0f 1e fb          	endbr32 
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 27d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 284:	eb 04                	jmp    28a <strlen+0x17>
 286:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 28a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	01 d0                	add    %edx,%eax
 292:	0f b6 00             	movzbl (%eax),%eax
 295:	84 c0                	test   %al,%al
 297:	75 ed                	jne    286 <strlen+0x13>
    ;
  return n;
 299:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29c:	c9                   	leave  
 29d:	c3                   	ret    

0000029e <memset>:

void*
memset(void *dst, int c, uint n)
{
 29e:	f3 0f 1e fb          	endbr32 
 2a2:	55                   	push   %ebp
 2a3:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2a5:	8b 45 10             	mov    0x10(%ebp),%eax
 2a8:	50                   	push   %eax
 2a9:	ff 75 0c             	pushl  0xc(%ebp)
 2ac:	ff 75 08             	pushl  0x8(%ebp)
 2af:	e8 22 ff ff ff       	call   1d6 <stosb>
 2b4:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ba:	c9                   	leave  
 2bb:	c3                   	ret    

000002bc <strchr>:

char*
strchr(const char *s, char c)
{
 2bc:	f3 0f 1e fb          	endbr32 
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 04             	sub    $0x4,%esp
 2c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2cc:	eb 14                	jmp    2e2 <strchr+0x26>
    if(*s == c)
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
 2d1:	0f b6 00             	movzbl (%eax),%eax
 2d4:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2d7:	75 05                	jne    2de <strchr+0x22>
      return (char*)s;
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	eb 13                	jmp    2f1 <strchr+0x35>
  for(; *s; s++)
 2de:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	0f b6 00             	movzbl (%eax),%eax
 2e8:	84 c0                	test   %al,%al
 2ea:	75 e2                	jne    2ce <strchr+0x12>
  return 0;
 2ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <gets>:

char*
gets(char *buf, int max)
{
 2f3:	f3 0f 1e fb          	endbr32 
 2f7:	55                   	push   %ebp
 2f8:	89 e5                	mov    %esp,%ebp
 2fa:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 304:	eb 42                	jmp    348 <gets+0x55>
    cc = read(0, &c, 1);
 306:	83 ec 04             	sub    $0x4,%esp
 309:	6a 01                	push   $0x1
 30b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 30e:	50                   	push   %eax
 30f:	6a 00                	push   $0x0
 311:	e8 53 01 00 00       	call   469 <read>
 316:	83 c4 10             	add    $0x10,%esp
 319:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 31c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 320:	7e 33                	jle    355 <gets+0x62>
      break;
    buf[i++] = c;
 322:	8b 45 f4             	mov    -0xc(%ebp),%eax
 325:	8d 50 01             	lea    0x1(%eax),%edx
 328:	89 55 f4             	mov    %edx,-0xc(%ebp)
 32b:	89 c2                	mov    %eax,%edx
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	01 c2                	add    %eax,%edx
 332:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 336:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 338:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33c:	3c 0a                	cmp    $0xa,%al
 33e:	74 16                	je     356 <gets+0x63>
 340:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 344:	3c 0d                	cmp    $0xd,%al
 346:	74 0e                	je     356 <gets+0x63>
  for(i=0; i+1 < max; ){
 348:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34b:	83 c0 01             	add    $0x1,%eax
 34e:	39 45 0c             	cmp    %eax,0xc(%ebp)
 351:	7f b3                	jg     306 <gets+0x13>
 353:	eb 01                	jmp    356 <gets+0x63>
      break;
 355:	90                   	nop
      break;
  }
  buf[i] = '\0';
 356:	8b 55 f4             	mov    -0xc(%ebp),%edx
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	01 d0                	add    %edx,%eax
 35e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 361:	8b 45 08             	mov    0x8(%ebp),%eax
}
 364:	c9                   	leave  
 365:	c3                   	ret    

00000366 <stat>:

int
stat(const char *n, struct stat *st)
{
 366:	f3 0f 1e fb          	endbr32 
 36a:	55                   	push   %ebp
 36b:	89 e5                	mov    %esp,%ebp
 36d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 370:	83 ec 08             	sub    $0x8,%esp
 373:	6a 00                	push   $0x0
 375:	ff 75 08             	pushl  0x8(%ebp)
 378:	e8 14 01 00 00       	call   491 <open>
 37d:	83 c4 10             	add    $0x10,%esp
 380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 383:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 387:	79 07                	jns    390 <stat+0x2a>
    return -1;
 389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 38e:	eb 25                	jmp    3b5 <stat+0x4f>
  r = fstat(fd, st);
 390:	83 ec 08             	sub    $0x8,%esp
 393:	ff 75 0c             	pushl  0xc(%ebp)
 396:	ff 75 f4             	pushl  -0xc(%ebp)
 399:	e8 0b 01 00 00       	call   4a9 <fstat>
 39e:	83 c4 10             	add    $0x10,%esp
 3a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3a4:	83 ec 0c             	sub    $0xc,%esp
 3a7:	ff 75 f4             	pushl  -0xc(%ebp)
 3aa:	e8 ca 00 00 00       	call   479 <close>
 3af:	83 c4 10             	add    $0x10,%esp
  return r;
 3b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3b5:	c9                   	leave  
 3b6:	c3                   	ret    

000003b7 <atoi>:

int
atoi(const char *s)
{
 3b7:	f3 0f 1e fb          	endbr32 
 3bb:	55                   	push   %ebp
 3bc:	89 e5                	mov    %esp,%ebp
 3be:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3c8:	eb 25                	jmp    3ef <atoi+0x38>
    n = n*10 + *s++ - '0';
 3ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3cd:	89 d0                	mov    %edx,%eax
 3cf:	c1 e0 02             	shl    $0x2,%eax
 3d2:	01 d0                	add    %edx,%eax
 3d4:	01 c0                	add    %eax,%eax
 3d6:	89 c1                	mov    %eax,%ecx
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	8d 50 01             	lea    0x1(%eax),%edx
 3de:	89 55 08             	mov    %edx,0x8(%ebp)
 3e1:	0f b6 00             	movzbl (%eax),%eax
 3e4:	0f be c0             	movsbl %al,%eax
 3e7:	01 c8                	add    %ecx,%eax
 3e9:	83 e8 30             	sub    $0x30,%eax
 3ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3ef:	8b 45 08             	mov    0x8(%ebp),%eax
 3f2:	0f b6 00             	movzbl (%eax),%eax
 3f5:	3c 2f                	cmp    $0x2f,%al
 3f7:	7e 0a                	jle    403 <atoi+0x4c>
 3f9:	8b 45 08             	mov    0x8(%ebp),%eax
 3fc:	0f b6 00             	movzbl (%eax),%eax
 3ff:	3c 39                	cmp    $0x39,%al
 401:	7e c7                	jle    3ca <atoi+0x13>
  return n;
 403:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 406:	c9                   	leave  
 407:	c3                   	ret    

00000408 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 408:	f3 0f 1e fb          	endbr32 
 40c:	55                   	push   %ebp
 40d:	89 e5                	mov    %esp,%ebp
 40f:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 412:	8b 45 08             	mov    0x8(%ebp),%eax
 415:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 418:	8b 45 0c             	mov    0xc(%ebp),%eax
 41b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 41e:	eb 17                	jmp    437 <memmove+0x2f>
    *dst++ = *src++;
 420:	8b 55 f8             	mov    -0x8(%ebp),%edx
 423:	8d 42 01             	lea    0x1(%edx),%eax
 426:	89 45 f8             	mov    %eax,-0x8(%ebp)
 429:	8b 45 fc             	mov    -0x4(%ebp),%eax
 42c:	8d 48 01             	lea    0x1(%eax),%ecx
 42f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 432:	0f b6 12             	movzbl (%edx),%edx
 435:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 437:	8b 45 10             	mov    0x10(%ebp),%eax
 43a:	8d 50 ff             	lea    -0x1(%eax),%edx
 43d:	89 55 10             	mov    %edx,0x10(%ebp)
 440:	85 c0                	test   %eax,%eax
 442:	7f dc                	jg     420 <memmove+0x18>
  return vdst;
 444:	8b 45 08             	mov    0x8(%ebp),%eax
}
 447:	c9                   	leave  
 448:	c3                   	ret    

00000449 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 449:	b8 01 00 00 00       	mov    $0x1,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <exit>:
SYSCALL(exit)
 451:	b8 02 00 00 00       	mov    $0x2,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <wait>:
SYSCALL(wait)
 459:	b8 03 00 00 00       	mov    $0x3,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <pipe>:
SYSCALL(pipe)
 461:	b8 04 00 00 00       	mov    $0x4,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret    

00000469 <read>:
SYSCALL(read)
 469:	b8 05 00 00 00       	mov    $0x5,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret    

00000471 <write>:
SYSCALL(write)
 471:	b8 10 00 00 00       	mov    $0x10,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret    

00000479 <close>:
SYSCALL(close)
 479:	b8 15 00 00 00       	mov    $0x15,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	ret    

00000481 <kill>:
SYSCALL(kill)
 481:	b8 06 00 00 00       	mov    $0x6,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	ret    

00000489 <exec>:
SYSCALL(exec)
 489:	b8 07 00 00 00       	mov    $0x7,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	ret    

00000491 <open>:
SYSCALL(open)
 491:	b8 0f 00 00 00       	mov    $0xf,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	ret    

00000499 <mknod>:
SYSCALL(mknod)
 499:	b8 11 00 00 00       	mov    $0x11,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	ret    

000004a1 <unlink>:
SYSCALL(unlink)
 4a1:	b8 12 00 00 00       	mov    $0x12,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	ret    

000004a9 <fstat>:
SYSCALL(fstat)
 4a9:	b8 08 00 00 00       	mov    $0x8,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	ret    

000004b1 <link>:
SYSCALL(link)
 4b1:	b8 13 00 00 00       	mov    $0x13,%eax
 4b6:	cd 40                	int    $0x40
 4b8:	c3                   	ret    

000004b9 <mkdir>:
SYSCALL(mkdir)
 4b9:	b8 14 00 00 00       	mov    $0x14,%eax
 4be:	cd 40                	int    $0x40
 4c0:	c3                   	ret    

000004c1 <chdir>:
SYSCALL(chdir)
 4c1:	b8 09 00 00 00       	mov    $0x9,%eax
 4c6:	cd 40                	int    $0x40
 4c8:	c3                   	ret    

000004c9 <dup>:
SYSCALL(dup)
 4c9:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	ret    

000004d1 <getpid>:
SYSCALL(getpid)
 4d1:	b8 0b 00 00 00       	mov    $0xb,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <sbrk>:
SYSCALL(sbrk)
 4d9:	b8 0c 00 00 00       	mov    $0xc,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <sleep>:
SYSCALL(sleep)
 4e1:	b8 0d 00 00 00       	mov    $0xd,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <uptime>:
SYSCALL(uptime)
 4e9:	b8 0e 00 00 00       	mov    $0xe,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <wait2>:
 4f1:	b8 16 00 00 00       	mov    $0x16,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f9:	f3 0f 1e fb          	endbr32 
 4fd:	55                   	push   %ebp
 4fe:	89 e5                	mov    %esp,%ebp
 500:	83 ec 18             	sub    $0x18,%esp
 503:	8b 45 0c             	mov    0xc(%ebp),%eax
 506:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 509:	83 ec 04             	sub    $0x4,%esp
 50c:	6a 01                	push   $0x1
 50e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 511:	50                   	push   %eax
 512:	ff 75 08             	pushl  0x8(%ebp)
 515:	e8 57 ff ff ff       	call   471 <write>
 51a:	83 c4 10             	add    $0x10,%esp
}
 51d:	90                   	nop
 51e:	c9                   	leave  
 51f:	c3                   	ret    

00000520 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 520:	f3 0f 1e fb          	endbr32 
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
 527:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 52a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 531:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 535:	74 17                	je     54e <printint+0x2e>
 537:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 53b:	79 11                	jns    54e <printint+0x2e>
    neg = 1;
 53d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 544:	8b 45 0c             	mov    0xc(%ebp),%eax
 547:	f7 d8                	neg    %eax
 549:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54c:	eb 06                	jmp    554 <printint+0x34>
  } else {
    x = xx;
 54e:	8b 45 0c             	mov    0xc(%ebp),%eax
 551:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 554:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 55b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 55e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 561:	ba 00 00 00 00       	mov    $0x0,%edx
 566:	f7 f1                	div    %ecx
 568:	89 d1                	mov    %edx,%ecx
 56a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56d:	8d 50 01             	lea    0x1(%eax),%edx
 570:	89 55 f4             	mov    %edx,-0xc(%ebp)
 573:	0f b6 91 2c 0d 00 00 	movzbl 0xd2c(%ecx),%edx
 57a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 57e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 581:	8b 45 ec             	mov    -0x14(%ebp),%eax
 584:	ba 00 00 00 00       	mov    $0x0,%edx
 589:	f7 f1                	div    %ecx
 58b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 58e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 592:	75 c7                	jne    55b <printint+0x3b>
  if(neg)
 594:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 598:	74 2d                	je     5c7 <printint+0xa7>
    buf[i++] = '-';
 59a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59d:	8d 50 01             	lea    0x1(%eax),%edx
 5a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5a3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5a8:	eb 1d                	jmp    5c7 <printint+0xa7>
    putc(fd, buf[i]);
 5aa:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b0:	01 d0                	add    %edx,%eax
 5b2:	0f b6 00             	movzbl (%eax),%eax
 5b5:	0f be c0             	movsbl %al,%eax
 5b8:	83 ec 08             	sub    $0x8,%esp
 5bb:	50                   	push   %eax
 5bc:	ff 75 08             	pushl  0x8(%ebp)
 5bf:	e8 35 ff ff ff       	call   4f9 <putc>
 5c4:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 5c7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5cf:	79 d9                	jns    5aa <printint+0x8a>
}
 5d1:	90                   	nop
 5d2:	90                   	nop
 5d3:	c9                   	leave  
 5d4:	c3                   	ret    

000005d5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5d5:	f3 0f 1e fb          	endbr32 
 5d9:	55                   	push   %ebp
 5da:	89 e5                	mov    %esp,%ebp
 5dc:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e6:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e9:	83 c0 04             	add    $0x4,%eax
 5ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f6:	e9 59 01 00 00       	jmp    754 <printf+0x17f>
    c = fmt[i] & 0xff;
 5fb:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 601:	01 d0                	add    %edx,%eax
 603:	0f b6 00             	movzbl (%eax),%eax
 606:	0f be c0             	movsbl %al,%eax
 609:	25 ff 00 00 00       	and    $0xff,%eax
 60e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 611:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 615:	75 2c                	jne    643 <printf+0x6e>
      if(c == '%'){
 617:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61b:	75 0c                	jne    629 <printf+0x54>
        state = '%';
 61d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 624:	e9 27 01 00 00       	jmp    750 <printf+0x17b>
      } else {
        putc(fd, c);
 629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62c:	0f be c0             	movsbl %al,%eax
 62f:	83 ec 08             	sub    $0x8,%esp
 632:	50                   	push   %eax
 633:	ff 75 08             	pushl  0x8(%ebp)
 636:	e8 be fe ff ff       	call   4f9 <putc>
 63b:	83 c4 10             	add    $0x10,%esp
 63e:	e9 0d 01 00 00       	jmp    750 <printf+0x17b>
      }
    } else if(state == '%'){
 643:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 647:	0f 85 03 01 00 00    	jne    750 <printf+0x17b>
      if(c == 'd'){
 64d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 651:	75 1e                	jne    671 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 653:	8b 45 e8             	mov    -0x18(%ebp),%eax
 656:	8b 00                	mov    (%eax),%eax
 658:	6a 01                	push   $0x1
 65a:	6a 0a                	push   $0xa
 65c:	50                   	push   %eax
 65d:	ff 75 08             	pushl  0x8(%ebp)
 660:	e8 bb fe ff ff       	call   520 <printint>
 665:	83 c4 10             	add    $0x10,%esp
        ap++;
 668:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66c:	e9 d8 00 00 00       	jmp    749 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 671:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 675:	74 06                	je     67d <printf+0xa8>
 677:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 67b:	75 1e                	jne    69b <printf+0xc6>
        printint(fd, *ap, 16, 0);
 67d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 680:	8b 00                	mov    (%eax),%eax
 682:	6a 00                	push   $0x0
 684:	6a 10                	push   $0x10
 686:	50                   	push   %eax
 687:	ff 75 08             	pushl  0x8(%ebp)
 68a:	e8 91 fe ff ff       	call   520 <printint>
 68f:	83 c4 10             	add    $0x10,%esp
        ap++;
 692:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 696:	e9 ae 00 00 00       	jmp    749 <printf+0x174>
      } else if(c == 's'){
 69b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 69f:	75 43                	jne    6e4 <printf+0x10f>
        s = (char*)*ap;
 6a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b1:	75 25                	jne    6d8 <printf+0x103>
          s = "(null)";
 6b3:	c7 45 f4 e0 0a 00 00 	movl   $0xae0,-0xc(%ebp)
        while(*s != 0){
 6ba:	eb 1c                	jmp    6d8 <printf+0x103>
          putc(fd, *s);
 6bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bf:	0f b6 00             	movzbl (%eax),%eax
 6c2:	0f be c0             	movsbl %al,%eax
 6c5:	83 ec 08             	sub    $0x8,%esp
 6c8:	50                   	push   %eax
 6c9:	ff 75 08             	pushl  0x8(%ebp)
 6cc:	e8 28 fe ff ff       	call   4f9 <putc>
 6d1:	83 c4 10             	add    $0x10,%esp
          s++;
 6d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6db:	0f b6 00             	movzbl (%eax),%eax
 6de:	84 c0                	test   %al,%al
 6e0:	75 da                	jne    6bc <printf+0xe7>
 6e2:	eb 65                	jmp    749 <printf+0x174>
        }
      } else if(c == 'c'){
 6e4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e8:	75 1d                	jne    707 <printf+0x132>
        putc(fd, *ap);
 6ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ed:	8b 00                	mov    (%eax),%eax
 6ef:	0f be c0             	movsbl %al,%eax
 6f2:	83 ec 08             	sub    $0x8,%esp
 6f5:	50                   	push   %eax
 6f6:	ff 75 08             	pushl  0x8(%ebp)
 6f9:	e8 fb fd ff ff       	call   4f9 <putc>
 6fe:	83 c4 10             	add    $0x10,%esp
        ap++;
 701:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 705:	eb 42                	jmp    749 <printf+0x174>
      } else if(c == '%'){
 707:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 70b:	75 17                	jne    724 <printf+0x14f>
        putc(fd, c);
 70d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 710:	0f be c0             	movsbl %al,%eax
 713:	83 ec 08             	sub    $0x8,%esp
 716:	50                   	push   %eax
 717:	ff 75 08             	pushl  0x8(%ebp)
 71a:	e8 da fd ff ff       	call   4f9 <putc>
 71f:	83 c4 10             	add    $0x10,%esp
 722:	eb 25                	jmp    749 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 724:	83 ec 08             	sub    $0x8,%esp
 727:	6a 25                	push   $0x25
 729:	ff 75 08             	pushl  0x8(%ebp)
 72c:	e8 c8 fd ff ff       	call   4f9 <putc>
 731:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 737:	0f be c0             	movsbl %al,%eax
 73a:	83 ec 08             	sub    $0x8,%esp
 73d:	50                   	push   %eax
 73e:	ff 75 08             	pushl  0x8(%ebp)
 741:	e8 b3 fd ff ff       	call   4f9 <putc>
 746:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 749:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 750:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 754:	8b 55 0c             	mov    0xc(%ebp),%edx
 757:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75a:	01 d0                	add    %edx,%eax
 75c:	0f b6 00             	movzbl (%eax),%eax
 75f:	84 c0                	test   %al,%al
 761:	0f 85 94 fe ff ff    	jne    5fb <printf+0x26>
    }
  }
}
 767:	90                   	nop
 768:	90                   	nop
 769:	c9                   	leave  
 76a:	c3                   	ret    

0000076b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 76b:	f3 0f 1e fb          	endbr32 
 76f:	55                   	push   %ebp
 770:	89 e5                	mov    %esp,%ebp
 772:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	83 e8 08             	sub    $0x8,%eax
 77b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	a1 48 0d 00 00       	mov    0xd48,%eax
 783:	89 45 fc             	mov    %eax,-0x4(%ebp)
 786:	eb 24                	jmp    7ac <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78b:	8b 00                	mov    (%eax),%eax
 78d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 790:	72 12                	jb     7a4 <free+0x39>
 792:	8b 45 f8             	mov    -0x8(%ebp),%eax
 795:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 798:	77 24                	ja     7be <free+0x53>
 79a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7a2:	72 1a                	jb     7be <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a7:	8b 00                	mov    (%eax),%eax
 7a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7af:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b2:	76 d4                	jbe    788 <free+0x1d>
 7b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b7:	8b 00                	mov    (%eax),%eax
 7b9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7bc:	73 ca                	jae    788 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c1:	8b 40 04             	mov    0x4(%eax),%eax
 7c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ce:	01 c2                	add    %eax,%edx
 7d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d3:	8b 00                	mov    (%eax),%eax
 7d5:	39 c2                	cmp    %eax,%edx
 7d7:	75 24                	jne    7fd <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	8b 50 04             	mov    0x4(%eax),%edx
 7df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e2:	8b 00                	mov    (%eax),%eax
 7e4:	8b 40 04             	mov    0x4(%eax),%eax
 7e7:	01 c2                	add    %eax,%edx
 7e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ec:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f2:	8b 00                	mov    (%eax),%eax
 7f4:	8b 10                	mov    (%eax),%edx
 7f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f9:	89 10                	mov    %edx,(%eax)
 7fb:	eb 0a                	jmp    807 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 10                	mov    (%eax),%edx
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 807:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 814:	8b 45 fc             	mov    -0x4(%ebp),%eax
 817:	01 d0                	add    %edx,%eax
 819:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 81c:	75 20                	jne    83e <free+0xd3>
    p->s.size += bp->s.size;
 81e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 821:	8b 50 04             	mov    0x4(%eax),%edx
 824:	8b 45 f8             	mov    -0x8(%ebp),%eax
 827:	8b 40 04             	mov    0x4(%eax),%eax
 82a:	01 c2                	add    %eax,%edx
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	8b 10                	mov    (%eax),%edx
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	89 10                	mov    %edx,(%eax)
 83c:	eb 08                	jmp    846 <free+0xdb>
  } else
    p->s.ptr = bp;
 83e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 841:	8b 55 f8             	mov    -0x8(%ebp),%edx
 844:	89 10                	mov    %edx,(%eax)
  freep = p;
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	a3 48 0d 00 00       	mov    %eax,0xd48
}
 84e:	90                   	nop
 84f:	c9                   	leave  
 850:	c3                   	ret    

00000851 <morecore>:

static Header*
morecore(uint nu)
{
 851:	f3 0f 1e fb          	endbr32 
 855:	55                   	push   %ebp
 856:	89 e5                	mov    %esp,%ebp
 858:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 85b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 862:	77 07                	ja     86b <morecore+0x1a>
    nu = 4096;
 864:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 86b:	8b 45 08             	mov    0x8(%ebp),%eax
 86e:	c1 e0 03             	shl    $0x3,%eax
 871:	83 ec 0c             	sub    $0xc,%esp
 874:	50                   	push   %eax
 875:	e8 5f fc ff ff       	call   4d9 <sbrk>
 87a:	83 c4 10             	add    $0x10,%esp
 87d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 880:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 884:	75 07                	jne    88d <morecore+0x3c>
    return 0;
 886:	b8 00 00 00 00       	mov    $0x0,%eax
 88b:	eb 26                	jmp    8b3 <morecore+0x62>
  hp = (Header*)p;
 88d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 890:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 893:	8b 45 f0             	mov    -0x10(%ebp),%eax
 896:	8b 55 08             	mov    0x8(%ebp),%edx
 899:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 89c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89f:	83 c0 08             	add    $0x8,%eax
 8a2:	83 ec 0c             	sub    $0xc,%esp
 8a5:	50                   	push   %eax
 8a6:	e8 c0 fe ff ff       	call   76b <free>
 8ab:	83 c4 10             	add    $0x10,%esp
  return freep;
 8ae:	a1 48 0d 00 00       	mov    0xd48,%eax
}
 8b3:	c9                   	leave  
 8b4:	c3                   	ret    

000008b5 <malloc>:

void*
malloc(uint nbytes)
{
 8b5:	f3 0f 1e fb          	endbr32 
 8b9:	55                   	push   %ebp
 8ba:	89 e5                	mov    %esp,%ebp
 8bc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8bf:	8b 45 08             	mov    0x8(%ebp),%eax
 8c2:	83 c0 07             	add    $0x7,%eax
 8c5:	c1 e8 03             	shr    $0x3,%eax
 8c8:	83 c0 01             	add    $0x1,%eax
 8cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8ce:	a1 48 0d 00 00       	mov    0xd48,%eax
 8d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8da:	75 23                	jne    8ff <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 8dc:	c7 45 f0 40 0d 00 00 	movl   $0xd40,-0x10(%ebp)
 8e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e6:	a3 48 0d 00 00       	mov    %eax,0xd48
 8eb:	a1 48 0d 00 00       	mov    0xd48,%eax
 8f0:	a3 40 0d 00 00       	mov    %eax,0xd40
    base.s.size = 0;
 8f5:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
 8fc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 902:	8b 00                	mov    (%eax),%eax
 904:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 907:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90a:	8b 40 04             	mov    0x4(%eax),%eax
 90d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 910:	77 4d                	ja     95f <malloc+0xaa>
      if(p->s.size == nunits)
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	8b 40 04             	mov    0x4(%eax),%eax
 918:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 91b:	75 0c                	jne    929 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 920:	8b 10                	mov    (%eax),%edx
 922:	8b 45 f0             	mov    -0x10(%ebp),%eax
 925:	89 10                	mov    %edx,(%eax)
 927:	eb 26                	jmp    94f <malloc+0x9a>
      else {
        p->s.size -= nunits;
 929:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92c:	8b 40 04             	mov    0x4(%eax),%eax
 92f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 932:	89 c2                	mov    %eax,%edx
 934:	8b 45 f4             	mov    -0xc(%ebp),%eax
 937:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 93a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93d:	8b 40 04             	mov    0x4(%eax),%eax
 940:	c1 e0 03             	shl    $0x3,%eax
 943:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	8b 55 ec             	mov    -0x14(%ebp),%edx
 94c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 94f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 952:	a3 48 0d 00 00       	mov    %eax,0xd48
      return (void*)(p + 1);
 957:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95a:	83 c0 08             	add    $0x8,%eax
 95d:	eb 3b                	jmp    99a <malloc+0xe5>
    }
    if(p == freep)
 95f:	a1 48 0d 00 00       	mov    0xd48,%eax
 964:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 967:	75 1e                	jne    987 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 969:	83 ec 0c             	sub    $0xc,%esp
 96c:	ff 75 ec             	pushl  -0x14(%ebp)
 96f:	e8 dd fe ff ff       	call   851 <morecore>
 974:	83 c4 10             	add    $0x10,%esp
 977:	89 45 f4             	mov    %eax,-0xc(%ebp)
 97a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 97e:	75 07                	jne    987 <malloc+0xd2>
        return 0;
 980:	b8 00 00 00 00       	mov    $0x0,%eax
 985:	eb 13                	jmp    99a <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 987:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	8b 00                	mov    (%eax),%eax
 992:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 995:	e9 6d ff ff ff       	jmp    907 <malloc+0x52>
  }
}
 99a:	c9                   	leave  
 99b:	c3                   	ret    
