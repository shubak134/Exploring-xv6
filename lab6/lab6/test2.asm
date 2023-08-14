
_test2:     file format elf32-i386


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
  31:	e8 88 03 00 00       	call   3be <atoi>
  36:	83 c4 10             	add    $0x10,%esp
  39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    printf(1, "*Case1: Parent has no children*\n");
  3c:	83 ec 08             	sub    $0x8,%esp
  3f:	68 a8 09 00 00       	push   $0x9a8
  44:	6a 01                	push   $0x1
  46:	e8 91 05 00 00       	call   5dc <printf>
  4b:	83 c4 10             	add    $0x10,%esp
    int wtime1, rtime1;
    int status = wait2(&wtime1, &rtime1);
  4e:	83 ec 08             	sub    $0x8,%esp
  51:	8d 45 dc             	lea    -0x24(%ebp),%eax
  54:	50                   	push   %eax
  55:	8d 45 e0             	lea    -0x20(%ebp),%eax
  58:	50                   	push   %eax
  59:	e8 9a 04 00 00       	call   4f8 <wait2>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(status == -1) {
  64:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
  68:	75 17                	jne    81 <main+0x81>
        printf(1, "wait2 status: %d\n", status);
  6a:	83 ec 04             	sub    $0x4,%esp
  6d:	ff 75 e8             	pushl  -0x18(%ebp)
  70:	68 c9 09 00 00       	push   $0x9c9
  75:	6a 01                	push   $0x1
  77:	e8 60 05 00 00       	call   5dc <printf>
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	eb 12                	jmp    93 <main+0x93>
    } else {
        printf(1, "wait2 should return -1 if calling process has no children\n");
  81:	83 ec 08             	sub    $0x8,%esp
  84:	68 dc 09 00 00       	push   $0x9dc
  89:	6a 01                	push   $0x1
  8b:	e8 4c 05 00 00       	call   5dc <printf>
  90:	83 c4 10             	add    $0x10,%esp
    }


    printf(1, "*Case2: Parent has children*\n");
  93:	83 ec 08             	sub    $0x8,%esp
  96:	68 17 0a 00 00       	push   $0xa17
  9b:	6a 01                	push   $0x1
  9d:	e8 3a 05 00 00       	call   5dc <printf>
  a2:	83 c4 10             	add    $0x10,%esp
    for ( int child = 0; child < NCHILD; child++ ) {
  a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  ac:	e9 cd 00 00 00       	jmp    17e <main+0x17e>
        int pid = fork ();
  b1:	e8 9a 03 00 00       	call   450 <fork>
  b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if ( pid < 0 ) {
  b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  bd:	79 1d                	jns    dc <main+0xdc>
            printf(1, "%d failed in fork!\n", getpid());
  bf:	e8 14 04 00 00       	call   4d8 <getpid>
  c4:	83 ec 04             	sub    $0x4,%esp
  c7:	50                   	push   %eax
  c8:	68 35 0a 00 00       	push   $0xa35
  cd:	6a 01                	push   $0x1
  cf:	e8 08 05 00 00       	call   5dc <printf>
  d4:	83 c4 10             	add    $0x10,%esp
            exit();
  d7:	e8 7c 03 00 00       	call   458 <exit>
        } else if (pid == 0) {
  dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  e0:	0f 85 94 00 00 00    	jne    17a <main+0x17a>
            sleep(100);
  e6:	83 ec 0c             	sub    $0xc,%esp
  e9:	6a 64                	push   $0x64
  eb:	e8 f8 03 00 00       	call   4e8 <sleep>
  f0:	83 c4 10             	add    $0x10,%esp
            printf(1, "Child %d created\n",getpid());
  f3:	e8 e0 03 00 00       	call   4d8 <getpid>
  f8:	83 ec 04             	sub    $0x4,%esp
  fb:	50                   	push   %eax
  fc:	68 49 0a 00 00       	push   $0xa49
 101:	6a 01                	push   $0x1
 103:	e8 d4 04 00 00       	call   5dc <printf>
 108:	83 c4 10             	add    $0x10,%esp
            volatile double a, b;
            a = 3.14;
 10b:	dd 05 c8 0a 00 00    	fldl   0xac8
 111:	dd 5d c8             	fstpl  -0x38(%ebp)
            b = 36.29;
 114:	dd 05 d0 0a 00 00    	fldl   0xad0
 11a:	dd 5d c0             	fstpl  -0x40(%ebp)
            volatile double x = 0, z;
 11d:	d9 ee                	fldz   
 11f:	dd 5d b8             	fstpl  -0x48(%ebp)
            for (z = 0; z < child * 90000.0; z += 0.1)
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
            for (z = 0; z < child * 90000.0; z += 0.1)
 139:	dd 45 b0             	fldl   -0x50(%ebp)
 13c:	dd 05 d8 0a 00 00    	fldl   0xad8
 142:	de c1                	faddp  %st,%st(1)
 144:	dd 5d b0             	fstpl  -0x50(%ebp)
 147:	db 45 f0             	fildl  -0x10(%ebp)
 14a:	dd 05 e0 0a 00 00    	fldl   0xae0
 150:	de c9                	fmulp  %st,%st(1)
 152:	dd 45 b0             	fldl   -0x50(%ebp)
 155:	d9 c9                	fxch   %st(1)
 157:	df f1                	fcomip %st(1),%st
 159:	dd d8                	fstp   %st(0)
 15b:	77 cc                	ja     129 <main+0x129>
            }
            printf(1, "Child %d finished\n",getpid());
 15d:	e8 76 03 00 00       	call   4d8 <getpid>
 162:	83 ec 04             	sub    $0x4,%esp
 165:	50                   	push   %eax
 166:	68 5b 0a 00 00       	push   $0xa5b
 16b:	6a 01                	push   $0x1
 16d:	e8 6a 04 00 00       	call   5dc <printf>
 172:	83 c4 10             	add    $0x10,%esp
            exit();
 175:	e8 de 02 00 00       	call   458 <exit>
    for ( int child = 0; child < NCHILD; child++ ) {
 17a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 17e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 181:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 184:	0f 8c 27 ff ff ff    	jl     b1 <main+0xb1>
        }
    }
    int wtime, rtime;
    for(int i=0; i<NCHILD; i++){
 18a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 191:	eb 3d                	jmp    1d0 <main+0x1d0>
        status = wait2(&wtime, &rtime);
 193:	83 ec 08             	sub    $0x8,%esp
 196:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 199:	50                   	push   %eax
 19a:	8d 45 d8             	lea    -0x28(%ebp),%eax
 19d:	50                   	push   %eax
 19e:	e8 55 03 00 00       	call   4f8 <wait2>
 1a3:	83 c4 10             	add    $0x10,%esp
 1a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        printf(1, "Child no. %d, Child pid: %d exited with Status: %d, Waiting Time: %d, Run Time: %d\n", i, status, status, wtime, rtime);
 1a9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 1ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
 1af:	83 ec 04             	sub    $0x4,%esp
 1b2:	52                   	push   %edx
 1b3:	50                   	push   %eax
 1b4:	ff 75 e8             	pushl  -0x18(%ebp)
 1b7:	ff 75 e8             	pushl  -0x18(%ebp)
 1ba:	ff 75 ec             	pushl  -0x14(%ebp)
 1bd:	68 70 0a 00 00       	push   $0xa70
 1c2:	6a 01                	push   $0x1
 1c4:	e8 13 04 00 00       	call   5dc <printf>
 1c9:	83 c4 20             	add    $0x20,%esp
    for(int i=0; i<NCHILD; i++){
 1cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 1d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1d3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 1d6:	7c bb                	jl     193 <main+0x193>
    }
    exit();
 1d8:	e8 7b 02 00 00       	call   458 <exit>

000001dd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1dd:	55                   	push   %ebp
 1de:	89 e5                	mov    %esp,%ebp
 1e0:	57                   	push   %edi
 1e1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1e5:	8b 55 10             	mov    0x10(%ebp),%edx
 1e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1eb:	89 cb                	mov    %ecx,%ebx
 1ed:	89 df                	mov    %ebx,%edi
 1ef:	89 d1                	mov    %edx,%ecx
 1f1:	fc                   	cld    
 1f2:	f3 aa                	rep stos %al,%es:(%edi)
 1f4:	89 ca                	mov    %ecx,%edx
 1f6:	89 fb                	mov    %edi,%ebx
 1f8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1fb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1fe:	90                   	nop
 1ff:	5b                   	pop    %ebx
 200:	5f                   	pop    %edi
 201:	5d                   	pop    %ebp
 202:	c3                   	ret    

00000203 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 203:	f3 0f 1e fb          	endbr32 
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 213:	90                   	nop
 214:	8b 55 0c             	mov    0xc(%ebp),%edx
 217:	8d 42 01             	lea    0x1(%edx),%eax
 21a:	89 45 0c             	mov    %eax,0xc(%ebp)
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
 220:	8d 48 01             	lea    0x1(%eax),%ecx
 223:	89 4d 08             	mov    %ecx,0x8(%ebp)
 226:	0f b6 12             	movzbl (%edx),%edx
 229:	88 10                	mov    %dl,(%eax)
 22b:	0f b6 00             	movzbl (%eax),%eax
 22e:	84 c0                	test   %al,%al
 230:	75 e2                	jne    214 <strcpy+0x11>
    ;
  return os;
 232:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 237:	f3 0f 1e fb          	endbr32 
 23b:	55                   	push   %ebp
 23c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 23e:	eb 08                	jmp    248 <strcmp+0x11>
    p++, q++;
 240:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 244:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	0f b6 00             	movzbl (%eax),%eax
 24e:	84 c0                	test   %al,%al
 250:	74 10                	je     262 <strcmp+0x2b>
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	0f b6 10             	movzbl (%eax),%edx
 258:	8b 45 0c             	mov    0xc(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	38 c2                	cmp    %al,%dl
 260:	74 de                	je     240 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	0f b6 00             	movzbl (%eax),%eax
 268:	0f b6 d0             	movzbl %al,%edx
 26b:	8b 45 0c             	mov    0xc(%ebp),%eax
 26e:	0f b6 00             	movzbl (%eax),%eax
 271:	0f b6 c0             	movzbl %al,%eax
 274:	29 c2                	sub    %eax,%edx
 276:	89 d0                	mov    %edx,%eax
}
 278:	5d                   	pop    %ebp
 279:	c3                   	ret    

0000027a <strlen>:

uint
strlen(const char *s)
{
 27a:	f3 0f 1e fb          	endbr32 
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 284:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 28b:	eb 04                	jmp    291 <strlen+0x17>
 28d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 291:	8b 55 fc             	mov    -0x4(%ebp),%edx
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	01 d0                	add    %edx,%eax
 299:	0f b6 00             	movzbl (%eax),%eax
 29c:	84 c0                	test   %al,%al
 29e:	75 ed                	jne    28d <strlen+0x13>
    ;
  return n;
 2a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a5:	f3 0f 1e fb          	endbr32 
 2a9:	55                   	push   %ebp
 2aa:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2ac:	8b 45 10             	mov    0x10(%ebp),%eax
 2af:	50                   	push   %eax
 2b0:	ff 75 0c             	pushl  0xc(%ebp)
 2b3:	ff 75 08             	pushl  0x8(%ebp)
 2b6:	e8 22 ff ff ff       	call   1dd <stosb>
 2bb:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <strchr>:

char*
strchr(const char *s, char c)
{
 2c3:	f3 0f 1e fb          	endbr32 
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 04             	sub    $0x4,%esp
 2cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2d3:	eb 14                	jmp    2e9 <strchr+0x26>
    if(*s == c)
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	0f b6 00             	movzbl (%eax),%eax
 2db:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2de:	75 05                	jne    2e5 <strchr+0x22>
      return (char*)s;
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	eb 13                	jmp    2f8 <strchr+0x35>
  for(; *s; s++)
 2e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	0f b6 00             	movzbl (%eax),%eax
 2ef:	84 c0                	test   %al,%al
 2f1:	75 e2                	jne    2d5 <strchr+0x12>
  return 0;
 2f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2f8:	c9                   	leave  
 2f9:	c3                   	ret    

000002fa <gets>:

char*
gets(char *buf, int max)
{
 2fa:	f3 0f 1e fb          	endbr32 
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
 301:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 304:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 30b:	eb 42                	jmp    34f <gets+0x55>
    cc = read(0, &c, 1);
 30d:	83 ec 04             	sub    $0x4,%esp
 310:	6a 01                	push   $0x1
 312:	8d 45 ef             	lea    -0x11(%ebp),%eax
 315:	50                   	push   %eax
 316:	6a 00                	push   $0x0
 318:	e8 53 01 00 00       	call   470 <read>
 31d:	83 c4 10             	add    $0x10,%esp
 320:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 323:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 327:	7e 33                	jle    35c <gets+0x62>
      break;
    buf[i++] = c;
 329:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32c:	8d 50 01             	lea    0x1(%eax),%edx
 32f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 332:	89 c2                	mov    %eax,%edx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	01 c2                	add    %eax,%edx
 339:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 33f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 343:	3c 0a                	cmp    $0xa,%al
 345:	74 16                	je     35d <gets+0x63>
 347:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 34b:	3c 0d                	cmp    $0xd,%al
 34d:	74 0e                	je     35d <gets+0x63>
  for(i=0; i+1 < max; ){
 34f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 352:	83 c0 01             	add    $0x1,%eax
 355:	39 45 0c             	cmp    %eax,0xc(%ebp)
 358:	7f b3                	jg     30d <gets+0x13>
 35a:	eb 01                	jmp    35d <gets+0x63>
      break;
 35c:	90                   	nop
      break;
  }
  buf[i] = '\0';
 35d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 360:	8b 45 08             	mov    0x8(%ebp),%eax
 363:	01 d0                	add    %edx,%eax
 365:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <stat>:

int
stat(const char *n, struct stat *st)
{
 36d:	f3 0f 1e fb          	endbr32 
 371:	55                   	push   %ebp
 372:	89 e5                	mov    %esp,%ebp
 374:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 377:	83 ec 08             	sub    $0x8,%esp
 37a:	6a 00                	push   $0x0
 37c:	ff 75 08             	pushl  0x8(%ebp)
 37f:	e8 14 01 00 00       	call   498 <open>
 384:	83 c4 10             	add    $0x10,%esp
 387:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 38a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 38e:	79 07                	jns    397 <stat+0x2a>
    return -1;
 390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 395:	eb 25                	jmp    3bc <stat+0x4f>
  r = fstat(fd, st);
 397:	83 ec 08             	sub    $0x8,%esp
 39a:	ff 75 0c             	pushl  0xc(%ebp)
 39d:	ff 75 f4             	pushl  -0xc(%ebp)
 3a0:	e8 0b 01 00 00       	call   4b0 <fstat>
 3a5:	83 c4 10             	add    $0x10,%esp
 3a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3ab:	83 ec 0c             	sub    $0xc,%esp
 3ae:	ff 75 f4             	pushl  -0xc(%ebp)
 3b1:	e8 ca 00 00 00       	call   480 <close>
 3b6:	83 c4 10             	add    $0x10,%esp
  return r;
 3b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <atoi>:

int
atoi(const char *s)
{
 3be:	f3 0f 1e fb          	endbr32 
 3c2:	55                   	push   %ebp
 3c3:	89 e5                	mov    %esp,%ebp
 3c5:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3cf:	eb 25                	jmp    3f6 <atoi+0x38>
    n = n*10 + *s++ - '0';
 3d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d4:	89 d0                	mov    %edx,%eax
 3d6:	c1 e0 02             	shl    $0x2,%eax
 3d9:	01 d0                	add    %edx,%eax
 3db:	01 c0                	add    %eax,%eax
 3dd:	89 c1                	mov    %eax,%ecx
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	8d 50 01             	lea    0x1(%eax),%edx
 3e5:	89 55 08             	mov    %edx,0x8(%ebp)
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	0f be c0             	movsbl %al,%eax
 3ee:	01 c8                	add    %ecx,%eax
 3f0:	83 e8 30             	sub    $0x30,%eax
 3f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3f6:	8b 45 08             	mov    0x8(%ebp),%eax
 3f9:	0f b6 00             	movzbl (%eax),%eax
 3fc:	3c 2f                	cmp    $0x2f,%al
 3fe:	7e 0a                	jle    40a <atoi+0x4c>
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	0f b6 00             	movzbl (%eax),%eax
 406:	3c 39                	cmp    $0x39,%al
 408:	7e c7                	jle    3d1 <atoi+0x13>
  return n;
 40a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40d:	c9                   	leave  
 40e:	c3                   	ret    

0000040f <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 40f:	f3 0f 1e fb          	endbr32 
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 419:	8b 45 08             	mov    0x8(%ebp),%eax
 41c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 41f:	8b 45 0c             	mov    0xc(%ebp),%eax
 422:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 425:	eb 17                	jmp    43e <memmove+0x2f>
    *dst++ = *src++;
 427:	8b 55 f8             	mov    -0x8(%ebp),%edx
 42a:	8d 42 01             	lea    0x1(%edx),%eax
 42d:	89 45 f8             	mov    %eax,-0x8(%ebp)
 430:	8b 45 fc             	mov    -0x4(%ebp),%eax
 433:	8d 48 01             	lea    0x1(%eax),%ecx
 436:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 439:	0f b6 12             	movzbl (%edx),%edx
 43c:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 43e:	8b 45 10             	mov    0x10(%ebp),%eax
 441:	8d 50 ff             	lea    -0x1(%eax),%edx
 444:	89 55 10             	mov    %edx,0x10(%ebp)
 447:	85 c0                	test   %eax,%eax
 449:	7f dc                	jg     427 <memmove+0x18>
  return vdst;
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 44e:	c9                   	leave  
 44f:	c3                   	ret    

00000450 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 450:	b8 01 00 00 00       	mov    $0x1,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <exit>:
SYSCALL(exit)
 458:	b8 02 00 00 00       	mov    $0x2,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <wait>:
SYSCALL(wait)
 460:	b8 03 00 00 00       	mov    $0x3,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <pipe>:
SYSCALL(pipe)
 468:	b8 04 00 00 00       	mov    $0x4,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <read>:
SYSCALL(read)
 470:	b8 05 00 00 00       	mov    $0x5,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <write>:
SYSCALL(write)
 478:	b8 10 00 00 00       	mov    $0x10,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <close>:
SYSCALL(close)
 480:	b8 15 00 00 00       	mov    $0x15,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <kill>:
SYSCALL(kill)
 488:	b8 06 00 00 00       	mov    $0x6,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <exec>:
SYSCALL(exec)
 490:	b8 07 00 00 00       	mov    $0x7,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <open>:
SYSCALL(open)
 498:	b8 0f 00 00 00       	mov    $0xf,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <mknod>:
SYSCALL(mknod)
 4a0:	b8 11 00 00 00       	mov    $0x11,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <unlink>:
SYSCALL(unlink)
 4a8:	b8 12 00 00 00       	mov    $0x12,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <fstat>:
SYSCALL(fstat)
 4b0:	b8 08 00 00 00       	mov    $0x8,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <link>:
SYSCALL(link)
 4b8:	b8 13 00 00 00       	mov    $0x13,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <mkdir>:
SYSCALL(mkdir)
 4c0:	b8 14 00 00 00       	mov    $0x14,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <chdir>:
SYSCALL(chdir)
 4c8:	b8 09 00 00 00       	mov    $0x9,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <dup>:
SYSCALL(dup)
 4d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <getpid>:
SYSCALL(getpid)
 4d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <sbrk>:
SYSCALL(sbrk)
 4e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <sleep>:
SYSCALL(sleep)
 4e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <uptime>:
SYSCALL(uptime)
 4f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <wait2>:
 4f8:	b8 16 00 00 00       	mov    $0x16,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 500:	f3 0f 1e fb          	endbr32 
 504:	55                   	push   %ebp
 505:	89 e5                	mov    %esp,%ebp
 507:	83 ec 18             	sub    $0x18,%esp
 50a:	8b 45 0c             	mov    0xc(%ebp),%eax
 50d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 510:	83 ec 04             	sub    $0x4,%esp
 513:	6a 01                	push   $0x1
 515:	8d 45 f4             	lea    -0xc(%ebp),%eax
 518:	50                   	push   %eax
 519:	ff 75 08             	pushl  0x8(%ebp)
 51c:	e8 57 ff ff ff       	call   478 <write>
 521:	83 c4 10             	add    $0x10,%esp
}
 524:	90                   	nop
 525:	c9                   	leave  
 526:	c3                   	ret    

00000527 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 527:	f3 0f 1e fb          	endbr32 
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 531:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 538:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 53c:	74 17                	je     555 <printint+0x2e>
 53e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 542:	79 11                	jns    555 <printint+0x2e>
    neg = 1;
 544:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 54b:	8b 45 0c             	mov    0xc(%ebp),%eax
 54e:	f7 d8                	neg    %eax
 550:	89 45 ec             	mov    %eax,-0x14(%ebp)
 553:	eb 06                	jmp    55b <printint+0x34>
  } else {
    x = xx;
 555:	8b 45 0c             	mov    0xc(%ebp),%eax
 558:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 55b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 562:	8b 4d 10             	mov    0x10(%ebp),%ecx
 565:	8b 45 ec             	mov    -0x14(%ebp),%eax
 568:	ba 00 00 00 00       	mov    $0x0,%edx
 56d:	f7 f1                	div    %ecx
 56f:	89 d1                	mov    %edx,%ecx
 571:	8b 45 f4             	mov    -0xc(%ebp),%eax
 574:	8d 50 01             	lea    0x1(%eax),%edx
 577:	89 55 f4             	mov    %edx,-0xc(%ebp)
 57a:	0f b6 91 34 0d 00 00 	movzbl 0xd34(%ecx),%edx
 581:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 585:	8b 4d 10             	mov    0x10(%ebp),%ecx
 588:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58b:	ba 00 00 00 00       	mov    $0x0,%edx
 590:	f7 f1                	div    %ecx
 592:	89 45 ec             	mov    %eax,-0x14(%ebp)
 595:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 599:	75 c7                	jne    562 <printint+0x3b>
  if(neg)
 59b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 59f:	74 2d                	je     5ce <printint+0xa7>
    buf[i++] = '-';
 5a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a4:	8d 50 01             	lea    0x1(%eax),%edx
 5a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5aa:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5af:	eb 1d                	jmp    5ce <printint+0xa7>
    putc(fd, buf[i]);
 5b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b7:	01 d0                	add    %edx,%eax
 5b9:	0f b6 00             	movzbl (%eax),%eax
 5bc:	0f be c0             	movsbl %al,%eax
 5bf:	83 ec 08             	sub    $0x8,%esp
 5c2:	50                   	push   %eax
 5c3:	ff 75 08             	pushl  0x8(%ebp)
 5c6:	e8 35 ff ff ff       	call   500 <putc>
 5cb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 5ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d6:	79 d9                	jns    5b1 <printint+0x8a>
}
 5d8:	90                   	nop
 5d9:	90                   	nop
 5da:	c9                   	leave  
 5db:	c3                   	ret    

000005dc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5dc:	f3 0f 1e fb          	endbr32 
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5e6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ed:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f0:	83 c0 04             	add    $0x4,%eax
 5f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5fd:	e9 59 01 00 00       	jmp    75b <printf+0x17f>
    c = fmt[i] & 0xff;
 602:	8b 55 0c             	mov    0xc(%ebp),%edx
 605:	8b 45 f0             	mov    -0x10(%ebp),%eax
 608:	01 d0                	add    %edx,%eax
 60a:	0f b6 00             	movzbl (%eax),%eax
 60d:	0f be c0             	movsbl %al,%eax
 610:	25 ff 00 00 00       	and    $0xff,%eax
 615:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 618:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61c:	75 2c                	jne    64a <printf+0x6e>
      if(c == '%'){
 61e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 622:	75 0c                	jne    630 <printf+0x54>
        state = '%';
 624:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62b:	e9 27 01 00 00       	jmp    757 <printf+0x17b>
      } else {
        putc(fd, c);
 630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 633:	0f be c0             	movsbl %al,%eax
 636:	83 ec 08             	sub    $0x8,%esp
 639:	50                   	push   %eax
 63a:	ff 75 08             	pushl  0x8(%ebp)
 63d:	e8 be fe ff ff       	call   500 <putc>
 642:	83 c4 10             	add    $0x10,%esp
 645:	e9 0d 01 00 00       	jmp    757 <printf+0x17b>
      }
    } else if(state == '%'){
 64a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 64e:	0f 85 03 01 00 00    	jne    757 <printf+0x17b>
      if(c == 'd'){
 654:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 658:	75 1e                	jne    678 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 65a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	6a 01                	push   $0x1
 661:	6a 0a                	push   $0xa
 663:	50                   	push   %eax
 664:	ff 75 08             	pushl  0x8(%ebp)
 667:	e8 bb fe ff ff       	call   527 <printint>
 66c:	83 c4 10             	add    $0x10,%esp
        ap++;
 66f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 673:	e9 d8 00 00 00       	jmp    750 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 678:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 67c:	74 06                	je     684 <printf+0xa8>
 67e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 682:	75 1e                	jne    6a2 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 684:	8b 45 e8             	mov    -0x18(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	6a 00                	push   $0x0
 68b:	6a 10                	push   $0x10
 68d:	50                   	push   %eax
 68e:	ff 75 08             	pushl  0x8(%ebp)
 691:	e8 91 fe ff ff       	call   527 <printint>
 696:	83 c4 10             	add    $0x10,%esp
        ap++;
 699:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69d:	e9 ae 00 00 00       	jmp    750 <printf+0x174>
      } else if(c == 's'){
 6a2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6a6:	75 43                	jne    6eb <printf+0x10f>
        s = (char*)*ap;
 6a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ab:	8b 00                	mov    (%eax),%eax
 6ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6b0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b8:	75 25                	jne    6df <printf+0x103>
          s = "(null)";
 6ba:	c7 45 f4 e8 0a 00 00 	movl   $0xae8,-0xc(%ebp)
        while(*s != 0){
 6c1:	eb 1c                	jmp    6df <printf+0x103>
          putc(fd, *s);
 6c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c6:	0f b6 00             	movzbl (%eax),%eax
 6c9:	0f be c0             	movsbl %al,%eax
 6cc:	83 ec 08             	sub    $0x8,%esp
 6cf:	50                   	push   %eax
 6d0:	ff 75 08             	pushl  0x8(%ebp)
 6d3:	e8 28 fe ff ff       	call   500 <putc>
 6d8:	83 c4 10             	add    $0x10,%esp
          s++;
 6db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e2:	0f b6 00             	movzbl (%eax),%eax
 6e5:	84 c0                	test   %al,%al
 6e7:	75 da                	jne    6c3 <printf+0xe7>
 6e9:	eb 65                	jmp    750 <printf+0x174>
        }
      } else if(c == 'c'){
 6eb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6ef:	75 1d                	jne    70e <printf+0x132>
        putc(fd, *ap);
 6f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	0f be c0             	movsbl %al,%eax
 6f9:	83 ec 08             	sub    $0x8,%esp
 6fc:	50                   	push   %eax
 6fd:	ff 75 08             	pushl  0x8(%ebp)
 700:	e8 fb fd ff ff       	call   500 <putc>
 705:	83 c4 10             	add    $0x10,%esp
        ap++;
 708:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70c:	eb 42                	jmp    750 <printf+0x174>
      } else if(c == '%'){
 70e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 712:	75 17                	jne    72b <printf+0x14f>
        putc(fd, c);
 714:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 717:	0f be c0             	movsbl %al,%eax
 71a:	83 ec 08             	sub    $0x8,%esp
 71d:	50                   	push   %eax
 71e:	ff 75 08             	pushl  0x8(%ebp)
 721:	e8 da fd ff ff       	call   500 <putc>
 726:	83 c4 10             	add    $0x10,%esp
 729:	eb 25                	jmp    750 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 72b:	83 ec 08             	sub    $0x8,%esp
 72e:	6a 25                	push   $0x25
 730:	ff 75 08             	pushl  0x8(%ebp)
 733:	e8 c8 fd ff ff       	call   500 <putc>
 738:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 73b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	83 ec 08             	sub    $0x8,%esp
 744:	50                   	push   %eax
 745:	ff 75 08             	pushl  0x8(%ebp)
 748:	e8 b3 fd ff ff       	call   500 <putc>
 74d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 750:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 757:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 75b:	8b 55 0c             	mov    0xc(%ebp),%edx
 75e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 761:	01 d0                	add    %edx,%eax
 763:	0f b6 00             	movzbl (%eax),%eax
 766:	84 c0                	test   %al,%al
 768:	0f 85 94 fe ff ff    	jne    602 <printf+0x26>
    }
  }
}
 76e:	90                   	nop
 76f:	90                   	nop
 770:	c9                   	leave  
 771:	c3                   	ret    

00000772 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 772:	f3 0f 1e fb          	endbr32 
 776:	55                   	push   %ebp
 777:	89 e5                	mov    %esp,%ebp
 779:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77c:	8b 45 08             	mov    0x8(%ebp),%eax
 77f:	83 e8 08             	sub    $0x8,%eax
 782:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 785:	a1 50 0d 00 00       	mov    0xd50,%eax
 78a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 78d:	eb 24                	jmp    7b3 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	8b 00                	mov    (%eax),%eax
 794:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 797:	72 12                	jb     7ab <free+0x39>
 799:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79f:	77 24                	ja     7c5 <free+0x53>
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7a9:	72 1a                	jb     7c5 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ae:	8b 00                	mov    (%eax),%eax
 7b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b9:	76 d4                	jbe    78f <free+0x1d>
 7bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7be:	8b 00                	mov    (%eax),%eax
 7c0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7c3:	73 ca                	jae    78f <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	8b 40 04             	mov    0x4(%eax),%eax
 7cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	01 c2                	add    %eax,%edx
 7d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7da:	8b 00                	mov    (%eax),%eax
 7dc:	39 c2                	cmp    %eax,%edx
 7de:	75 24                	jne    804 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e3:	8b 50 04             	mov    0x4(%eax),%edx
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 00                	mov    (%eax),%eax
 7eb:	8b 40 04             	mov    0x4(%eax),%eax
 7ee:	01 c2                	add    %eax,%edx
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f9:	8b 00                	mov    (%eax),%eax
 7fb:	8b 10                	mov    (%eax),%edx
 7fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 800:	89 10                	mov    %edx,(%eax)
 802:	eb 0a                	jmp    80e <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 804:	8b 45 fc             	mov    -0x4(%ebp),%eax
 807:	8b 10                	mov    (%eax),%edx
 809:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 81b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81e:	01 d0                	add    %edx,%eax
 820:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 823:	75 20                	jne    845 <free+0xd3>
    p->s.size += bp->s.size;
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	8b 50 04             	mov    0x4(%eax),%edx
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	8b 40 04             	mov    0x4(%eax),%eax
 831:	01 c2                	add    %eax,%edx
 833:	8b 45 fc             	mov    -0x4(%ebp),%eax
 836:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 839:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83c:	8b 10                	mov    (%eax),%edx
 83e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 841:	89 10                	mov    %edx,(%eax)
 843:	eb 08                	jmp    84d <free+0xdb>
  } else
    p->s.ptr = bp;
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 55 f8             	mov    -0x8(%ebp),%edx
 84b:	89 10                	mov    %edx,(%eax)
  freep = p;
 84d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 850:	a3 50 0d 00 00       	mov    %eax,0xd50
}
 855:	90                   	nop
 856:	c9                   	leave  
 857:	c3                   	ret    

00000858 <morecore>:

static Header*
morecore(uint nu)
{
 858:	f3 0f 1e fb          	endbr32 
 85c:	55                   	push   %ebp
 85d:	89 e5                	mov    %esp,%ebp
 85f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 862:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 869:	77 07                	ja     872 <morecore+0x1a>
    nu = 4096;
 86b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 872:	8b 45 08             	mov    0x8(%ebp),%eax
 875:	c1 e0 03             	shl    $0x3,%eax
 878:	83 ec 0c             	sub    $0xc,%esp
 87b:	50                   	push   %eax
 87c:	e8 5f fc ff ff       	call   4e0 <sbrk>
 881:	83 c4 10             	add    $0x10,%esp
 884:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 887:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 88b:	75 07                	jne    894 <morecore+0x3c>
    return 0;
 88d:	b8 00 00 00 00       	mov    $0x0,%eax
 892:	eb 26                	jmp    8ba <morecore+0x62>
  hp = (Header*)p;
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 89a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89d:	8b 55 08             	mov    0x8(%ebp),%edx
 8a0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a6:	83 c0 08             	add    $0x8,%eax
 8a9:	83 ec 0c             	sub    $0xc,%esp
 8ac:	50                   	push   %eax
 8ad:	e8 c0 fe ff ff       	call   772 <free>
 8b2:	83 c4 10             	add    $0x10,%esp
  return freep;
 8b5:	a1 50 0d 00 00       	mov    0xd50,%eax
}
 8ba:	c9                   	leave  
 8bb:	c3                   	ret    

000008bc <malloc>:

void*
malloc(uint nbytes)
{
 8bc:	f3 0f 1e fb          	endbr32 
 8c0:	55                   	push   %ebp
 8c1:	89 e5                	mov    %esp,%ebp
 8c3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c6:	8b 45 08             	mov    0x8(%ebp),%eax
 8c9:	83 c0 07             	add    $0x7,%eax
 8cc:	c1 e8 03             	shr    $0x3,%eax
 8cf:	83 c0 01             	add    $0x1,%eax
 8d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d5:	a1 50 0d 00 00       	mov    0xd50,%eax
 8da:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e1:	75 23                	jne    906 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 8e3:	c7 45 f0 48 0d 00 00 	movl   $0xd48,-0x10(%ebp)
 8ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ed:	a3 50 0d 00 00       	mov    %eax,0xd50
 8f2:	a1 50 0d 00 00       	mov    0xd50,%eax
 8f7:	a3 48 0d 00 00       	mov    %eax,0xd48
    base.s.size = 0;
 8fc:	c7 05 4c 0d 00 00 00 	movl   $0x0,0xd4c
 903:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 906:	8b 45 f0             	mov    -0x10(%ebp),%eax
 909:	8b 00                	mov    (%eax),%eax
 90b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 90e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 911:	8b 40 04             	mov    0x4(%eax),%eax
 914:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 917:	77 4d                	ja     966 <malloc+0xaa>
      if(p->s.size == nunits)
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	8b 40 04             	mov    0x4(%eax),%eax
 91f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 922:	75 0c                	jne    930 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 10                	mov    (%eax),%edx
 929:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92c:	89 10                	mov    %edx,(%eax)
 92e:	eb 26                	jmp    956 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 930:	8b 45 f4             	mov    -0xc(%ebp),%eax
 933:	8b 40 04             	mov    0x4(%eax),%eax
 936:	2b 45 ec             	sub    -0x14(%ebp),%eax
 939:	89 c2                	mov    %eax,%edx
 93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 941:	8b 45 f4             	mov    -0xc(%ebp),%eax
 944:	8b 40 04             	mov    0x4(%eax),%eax
 947:	c1 e0 03             	shl    $0x3,%eax
 94a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 94d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 950:	8b 55 ec             	mov    -0x14(%ebp),%edx
 953:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 956:	8b 45 f0             	mov    -0x10(%ebp),%eax
 959:	a3 50 0d 00 00       	mov    %eax,0xd50
      return (void*)(p + 1);
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	83 c0 08             	add    $0x8,%eax
 964:	eb 3b                	jmp    9a1 <malloc+0xe5>
    }
    if(p == freep)
 966:	a1 50 0d 00 00       	mov    0xd50,%eax
 96b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 96e:	75 1e                	jne    98e <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 970:	83 ec 0c             	sub    $0xc,%esp
 973:	ff 75 ec             	pushl  -0x14(%ebp)
 976:	e8 dd fe ff ff       	call   858 <morecore>
 97b:	83 c4 10             	add    $0x10,%esp
 97e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 985:	75 07                	jne    98e <malloc+0xd2>
        return 0;
 987:	b8 00 00 00 00       	mov    $0x0,%eax
 98c:	eb 13                	jmp    9a1 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	89 45 f0             	mov    %eax,-0x10(%ebp)
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 00                	mov    (%eax),%eax
 999:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 99c:	e9 6d ff ff ff       	jmp    90e <malloc+0x52>
  }
}
 9a1:	c9                   	leave  
 9a2:	c3                   	ret    
