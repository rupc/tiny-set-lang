# Tiny Set Language(TSL)
TSL은 수학의 집합 개념을 모사하려는 언어이다. 2014년도 2학기 컴파일러 수업 때 개발되었다.  
flex와 bison은 tsl.l, tsl.y를 읽어 어휘 목록과 문법을 정의하고 tslAST.c, tslAST.h는 TSL의 샘플 언어인 sam1.c를 읽고 파싱하여 x86 어셈블리 코드를 생성한다.  
exec-cmd.sh 실행하기 위한 쉘 명령어 모음이다.

###### [TSL에 대한 간략한 소개](docs/language-menual.pdf)  
###### [Definition of TSL](docs/language-definition.pdf)